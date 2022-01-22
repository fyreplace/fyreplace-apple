import UIKit

class BlockedUserTableViewCell: AvatarTableViewCell {
    @IBOutlet
    var username: UILabel!

    override func setup(with profile: FPProfile) {
        super.setup(with: profile)
        username.setUsername(profile)
    }
}
