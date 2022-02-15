import Kingfisher
import UIKit

extension UIButton {
    func setUsername(_ profile: FPProfile) {
        guard !profile.isAvailable, let font = titleLabel?.font else {
            setAttributedTitle(nil, for: .normal)
            return setTitle(profile.username, for: .normal)
        }

        setAttributedTitle(profile.getNormalizedUsername(with: font), for: .normal)
    }

    func setAvatar(_ url: String?) {
        let defaultImage = UIImage(called: "person.crop.circle.fill")

        if let url = url {
            kf.setImage(with: URL(string: url), for: .normal, placeholder: defaultImage)
        } else {
            setImage(defaultImage, for: .normal)
        }
    }
}
