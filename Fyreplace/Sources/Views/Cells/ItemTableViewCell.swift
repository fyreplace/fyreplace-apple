import Kingfisher
import UIKit

class ItemTableViewCell: AvatarTableViewCell {
    @IBOutlet
    var username: UILabel?
    @IBOutlet
    var date: UILabel?
    @IBOutlet
    var dateFormat: DateFormat?

    override func setup(withProfile profile: FPProfile) {
        super.setup(withProfile: profile)
        username?.setUsername(profile)
    }

    func setup(withProfile profile: FPProfile, at date: Date) {
        setup(withProfile: profile)
        self.date?.text = dateFormat?.string(from: date)
    }
}

class TextItemTableViewCell: ItemTableViewCell {
    @IBOutlet
    var preview: UILabel!

    func setup(withText text: String) {
        preview.text = text
    }
}

class ImageItemTableViewCell: ItemTableViewCell {
    @IBOutlet
    var preview: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        preview.kf.indicatorType = .activity
    }

    func setup(withUrl url: URL?) {
        preview.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
}
