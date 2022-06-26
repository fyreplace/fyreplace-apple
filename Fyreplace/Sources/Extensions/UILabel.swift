import UIKit

extension UILabel {
    func setUsername(_ profile: FPProfile) {
        attributedText = profile.getNormalizedUsername(with: font)
    }
}
