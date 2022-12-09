import SDWebImage
import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet
    weak var delegate: FeedTableViewCellDelegate!
    @IBOutlet
    var down: UIButton!
    @IBOutlet
    var up: UIButton!

    @IBAction
    func onDownPressed() {
        delegate.feedTableViewCell(self, didSpread: false)
    }

    @IBAction
    func onUpPressed() {
        delegate.feedTableViewCell(self, didSpread: true)
    }

    func setup(withPost post: FPPost) {
        for button in [down, up] {
            button?.isEnabled = currentUser != nil
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
