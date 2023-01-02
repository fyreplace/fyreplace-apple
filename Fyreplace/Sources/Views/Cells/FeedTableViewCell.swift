import ReactiveSwift
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
    private var trash: [Disposable] = []

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

        for disposable in trash {
            disposable.dispose()
        }

        trash.append(NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didReceiveRemoteNotificationNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onAppDidReceiveRemoteNotification($0) }!)

        trash.append(NotificationCenter.default.reactive
            .notifications(forName: FPComment.wasCreatedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentWasCreated($0) }!)
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
        button.tintColor = .tintColorCompat
        feedbackGenerator.selectionChanged()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            delegate.feedTableViewCell(self, didSpread: button == up)
            isVoting = false
            button.tintColor = .labelCompat
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
