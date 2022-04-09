import Kingfisher
import UIKit

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
