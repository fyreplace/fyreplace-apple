import Kingfisher
import UIKit

class ImageItemTableViewCell: ItemTableViewCell {
    @IBOutlet
    var preview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        preview.kf.indicatorType = .activity
    }
}
