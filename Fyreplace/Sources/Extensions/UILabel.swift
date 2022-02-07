import UIKit

extension UILabel {
    func setUsername(_ profile: FPProfile) {
        if profile.isAvailable {
            attributedText = nil
            text = profile.username
        } else {
            attributedText = profile.getNormalizedUsername(with: font)
        }
    }
}
