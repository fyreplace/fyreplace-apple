import SDWebImage
import UIKit

extension UIImageView {
    func setAvatar(from profile: FPProfile?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let profile, !profile.isBanned {
            sd_setImage(
                with: .init(string: profile.avatar.url),
                placeholderImage: defaultImage
            )
        } else {
            image = defaultImage
        }
    }
}
