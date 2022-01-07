import UIKit

extension UILabel {
    func setUsername(_ profile: FPProfile) {
        guard !profile.isAvailable else {
            return text = profile.username
        }

        attributedText = profile.getNormalizedUsername(with: font)
    }
}
