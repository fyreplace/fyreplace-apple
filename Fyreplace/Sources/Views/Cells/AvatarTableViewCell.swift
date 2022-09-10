import UIKit

class AvatarTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView?

    func setup(withProfile profile: FPProfile) {
        avatar?.setAvatar(from: profile)
    }
}
