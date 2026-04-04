import Combine
import SDWebImage
import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet
    weak var delegate: FeedTableViewCellDelegate!
    @IBOutlet
    var down: UIButton!
    @IBOutlet
    var up: UIButton!
    @IBOutlet
    var votes: UILabel!
    @IBOutlet
    var comments: UILabel!

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var isVoting = false
    private var postId: Data?
    private var cancellables = Set<AnyCancellable>()

    @IBAction
    func onDownPressed() {
        vote(with: down)
    }

    @IBAction
    func onUpPressed() {
        vote(with: up)
    }

    func setup(withPost post: FPPost) {
        for button in [down, up] {
            button?.isEnabled = currentUser != nil
        }

        votes.text = String(post.voteCount)
        comments.text = String(post.commentCount)
        postId = post.id
        cancellables.removeAll()

        NotificationCenter.default
            .publisher(for: AppDelegate.didReceiveRemoteNotificationNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onAppDidReceiveRemoteNotification($0) }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: FPComment.wasCreatedNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onCommentWasCreated($0) }
            .store(in: &cancellables)
    }

    private func onAppDidReceiveRemoteNotification(_ notification: Notification) {
        guard let info = notification.userInfo,
              let command = info["_command"] as? String,
              command == "comment:creation",
              let postIdString = info["postId"] as? String,
              let postId = Data(base64ShortString: postIdString),
              postId == self.postId
        else { return }
        incrementCommentCount()
    }

    private func onCommentWasCreated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let postId = info["postId"] as? Data,
              postId == self.postId
        else { return }
        incrementCommentCount()
    }

    private func vote(with button: UIButton) {
        guard !isVoting else { return }
        isVoting = true
        button.tintColor = .tintColor
        feedbackGenerator.selectionChanged()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            delegate.feedTableViewCell(self, didSpread: button == up)
            isVoting = false
            button.tintColor = .label
        }
    }

    private func incrementCommentCount() {
        comments.text = String((Int(comments.text ?? "0") ?? 0) + 1)
    }
}

class TextPostFeedTableViewCell: FeedTableViewCell {
    @IBOutlet
    var preview: UILabel!

    override func setup(withPost post: FPPost) {
        super.setup(withPost: post)
        preview.text = post.chapters.first?.text
    }
}

class ImagePostFeedTableViewCell: FeedTableViewCell {
    @IBOutlet
    var preview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        preview.sd_imageIndicator = SDWebImageProgressIndicator.default
        preview.sd_imageTransition = .fade
    }

    override func setup(withPost post: FPPost) {
        super.setup(withPost: post)
        guard let chapter = post.chapters.first else { return }
        preview.sd_setImage(with: .init(string: chapter.image.url))
    }
}

@objc
protocol FeedTableViewCellDelegate {
    func feedTableViewCell(_ cell: FeedTableViewCell, didSpread spread: Bool)
}
