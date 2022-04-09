import Kingfisher
import UIKit

class AvatarTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView!

    func setup(with profile: FPProfile) {
        avatar.setAvatar(profile.avatar.url)
    }
}
