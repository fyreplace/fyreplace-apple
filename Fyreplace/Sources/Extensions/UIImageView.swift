import Kingfisher
import UIKit

extension UIImageView {
    func setAvatar(from profile: FPProfile?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let profile, !profile.isBanned {
            kf.setImage(
                with: URL(string: profile.avatar.url),
                placeholder: defaultImage,
                options: [.transition(.fade(0.3))]
            )
        } else {
            image = defaultImage
        }
    }
}
