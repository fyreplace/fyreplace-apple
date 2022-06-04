import UIKit

extension FPProfile {
    var isAvailable: Bool { !isBanned && !username.isEmpty }

    func getNormalizedUsername(with font: UIFont?) -> NSAttributedString {
        let anonymous = username.count == 0
        let name: String

        if isBanned {
            name = .tr("Banned")
        } else if anonymous {
            name = .tr("Anonymous")
        } else {
            return NSAttributedString(string: username)
        }

        let attributes = (font != nil) ? [NSAttributedString.Key.font: font!.withTraits(.traitItalic)] : nil
        return NSAttributedString(string: name, attributes: attributes)
    }
}
