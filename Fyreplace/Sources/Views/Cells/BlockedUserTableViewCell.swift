import UIKit

class BlockedUserTableViewCell: AvatarTableViewCell {
    @IBOutlet
    var username: UILabel!

    override func setup(withProfile profile: FPProfile) {
        super.setup(withProfile: profile)
        username.setUsername(profile)
    }
}
