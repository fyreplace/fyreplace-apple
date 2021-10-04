import UIKit
import SDWebImage

class ImageItemTableViewCell: ItemTableViewCell {
    @IBOutlet
    var preview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        preview.sd_imageTransition = .fade
        preview.sd_imageIndicator = SDWebImageActivityIndicator.large
    }
}
