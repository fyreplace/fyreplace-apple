import UIKit

class AvatarTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView?

    func setup(with profile: FPProfile) {
        avatar?.setAvatar(from: profile)
    }
}
