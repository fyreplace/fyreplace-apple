import Kingfisher
import UIKit

extension UIImageView {
    func setAvatar(_ url: String?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let url = url {
            kf.setImage(
                with: URL(string: url),
                placeholder: defaultImage,
                options: [.transition(.fade(0.3))]
            )
        } else {
            image = defaultImage
        }
    }
}
