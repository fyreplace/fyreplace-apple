import SDWebImage
import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet
    weak var delegate: FeedTableViewCellDelegate!
    @IBOutlet
    var down: UIButton!
    @IBOutlet
    var up: UIButton!

    private let feedbackGenerator = UISelectionFeedbackGenerator()
    private var isVoting = false

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
    }

    private func vote(with button: UIButton) {
        guard !isVoting else { return }
        isVoting = true
        button.tintColor = .tintColorCompat
        feedbackGenerator.selectionChanged()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            delegate.feedTableViewCell(self, didSpread: button == up)
            isVoting = false
            button.tintColor = .labelCompat
        }
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
