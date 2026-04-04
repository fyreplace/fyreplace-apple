import SDWebImage
import UIKit

extension UIButton {
    func setUsername(_ profile: FPProfile) {
        setAttributedTitle(profile.getNormalizedUsername(with: titleLabel?.font), for: .normal)
    }

    func setAvatar(from profile: FPProfile?) {
        let defaultImage = UIImage(systemName: "person.crop.circle.fill")

        if let profile, !profile.isBanned {
            SDWebImageManager.shared.loadImage(with: .init(string: profile.avatar.url), progress: nil) { image, _, _, _, _, _ in
                let size = CGSize(width: 32, height: 32)
                guard let resized = image?.resized(at: size.width),
                      let rounded = resized.sd_roundedCornerImage(withRadius: size.width / 2, corners: .allCorners, borderWidth: 0, borderColor: nil)
                else { return }
                self.setImage(rounded, for: .normal)
            }
        } else {
            setImage(defaultImage, for: .normal)
        }
    }
}
