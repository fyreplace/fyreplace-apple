import UIKit
import SDWebImage

class ItemTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView!
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var date: UILabel!
    @IBOutlet
    var dateFormat: DateFormat!

    private var textContent: UITextView!
    private var imageContent: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.sd_imageTransition = .fade
    }

    func setup(at date: Date, from profile: FPProfile) {
        avatar.setAvatar(profile.avatar.url)
        self.date.text = dateFormat.string(from: date)
        username.setUsername(profile)
    }
}
