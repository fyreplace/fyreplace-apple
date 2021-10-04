import UIKit
import SDWebImage

class ItemTableViewCell: UITableViewCell {
    @IBOutlet
    var date: UILabel!
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var avatar: UIImageView!

    private var textContent: UITextView!
    private var imageContent: UIImageView!
    private let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.sd_imageTransition = .fade
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }

    func setup(at date: Date, from user: FPProfile) {
        self.date.text = dateFormatter.string(from: date)
        username.text = user.username
        avatar.setAvatar(user.avatar.url)
    }
}
