import Kingfisher
import UIKit

class PostTableViewCell: ItemTableViewCell {
    func setup(with post: FPPost) {
        setup(at: post.dateCreated.date, with: post.author)
        guard let chapter = post.chapters.first else { return }
        setup(with: chapter)
    }

    func setup(with chapter: FPChapter) {}
}

class TextPostTableViewCell: PostTableViewCell {
    @IBOutlet
    var preview: UILabel!

    override func setup(with chapter: FPChapter) {
        preview.font = chapter.preferredFont
        preview.text = chapter.text
    }
}

class ImagePostTableViewCell: PostTableViewCell {
    @IBOutlet
    var preview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        preview.kf.indicatorType = .activity
    }

    override func setup(with chapter: FPChapter) {
        preview.kf.setImage(
            with: URL(string: chapter.image.url),
            options: [.transition(.fade(0.3))]
        )
    }
}
