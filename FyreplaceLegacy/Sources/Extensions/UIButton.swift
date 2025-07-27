import SDWebImage
import UIKit

extension UIButton {
    func setUsername(_ profile: FPProfile) {
        setAttributedTitle(profile.getNormalizedUsername(with: titleLabel?.font), for: .normal)
    }

    func setAvatar(from profile: FPProfile?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let profile, !profile.isBanned {
            sd_setImage(
                with: .init(string: profile.avatar.url),
                for: .normal,
                placeholderImage: defaultImage
            )
        } else {
            setImage(defaultImage, for: .normal)
        }

        imageView?.contentMode = .scaleAspectFill
    }
}
