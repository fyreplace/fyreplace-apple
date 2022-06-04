import Kingfisher
import UIKit

extension UIButton {
    func setUsername(_ profile: FPProfile) {
        setAttributedTitle(profile.getNormalizedUsername(with: titleLabel?.font), for: .normal)
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
