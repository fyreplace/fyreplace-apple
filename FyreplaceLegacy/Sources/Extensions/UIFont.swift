import UIKit

extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        guard let fd = fontDescriptor.withSymbolicTraits(traits) else { return self }
        return .init(descriptor: fd, size: pointSize)
    }
}
