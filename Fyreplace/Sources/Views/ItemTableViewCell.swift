import UIKit

class ItemTableViewCell: AvatarTableViewCell {
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var date: UILabel!
    @IBOutlet
    var dateFormat: DateFormat!

    func setup(at date: Date, with profile: FPProfile) {
        setup(with: profile)
        self.date.text = dateFormat.string(from: date)
        username.setUsername(profile)
    }
}
