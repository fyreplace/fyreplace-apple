import Kingfisher
import UIKit

extension UIButton {
    func setUsername(_ profile: FPProfile) {
        setAttributedTitle(profile.getNormalizedUsername(with: titleLabel?.font), for: .normal)
    }

    func setAvatar(from profile: FPProfile?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let profile = profile, !profile.isBanned {
            kf.setImage(
                with: URL(string: profile.avatar.url),
                for: .normal,
                placeholder: defaultImage
            )
        } else {
            setImage(defaultImage, for: .normal)
        }
    }
}
