import SDWebImage
import UIKit

class AvatarTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar?.sd_imageTransition = .fade
    }

    func setup(withProfile profile: FPProfile) {
        avatar?.setAvatar(from: profile)
    }
}
