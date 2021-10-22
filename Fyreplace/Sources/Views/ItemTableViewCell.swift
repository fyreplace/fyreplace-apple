import UIKit
import SDWebImage

class ItemTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIImageView!
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var date: UILabel!

    private var textContent: UITextView!
    private var imageContent: UIImageView!
    private let dateFormatter = DateFormatter()

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.sd_imageTransition = .fade
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }

    func setup(at date: Date, from profile: FPProfile) {
        avatar.setAvatar(profile.avatar.url)
        self.date.text = dateFormatter.string(from: date)
        let anonymous = profile.username.count == 0
        let name = anonymous ? .tr("Anonymous") : profile.username
        let attributes = anonymous ? [NSAttributedString.Key.font: username.font.withTraits(.traitItalic)] : nil
        username.attributedText = NSAttributedString(string: name, attributes: attributes)
    }
}
