import SDWebImage
import UIKit

extension UIImageView {
    func setAvatar(_ url: String?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let url = url {
            sd_setImage(with: URL(string: url), placeholderImage: defaultImage)
        } else {
            image = defaultImage
        }
    }
}
