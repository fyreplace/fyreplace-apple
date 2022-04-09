import UIKit

class ItemTableViewCell: AvatarTableViewCell {
    @IBOutlet
    var username: UILabel?
    @IBOutlet
    var date: UILabel?
    @IBOutlet
    var dateFormat: DateFormat?

    override func setup(with profile: FPProfile) {
        super.setup(with: profile)
        username?.setUsername(profile)
    }

    func setup(at date: Date, with profile: FPProfile) {
        setup(with: profile)
        self.date?.text = dateFormat?.string(from: date)
    }
}
