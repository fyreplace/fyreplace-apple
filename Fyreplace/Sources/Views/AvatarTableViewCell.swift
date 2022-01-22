import UIKit
import SDWebImage

class AvatarTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.sd_imageTransition = .fade
    }

    func setup(with profile: FPProfile) {
        avatar.setAvatar(profile.avatar.url)
    }
}
