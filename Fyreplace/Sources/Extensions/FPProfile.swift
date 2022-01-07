import UIKit

extension FPProfile {
    var isAvailable: Bool { !isBanned && !username.isEmpty }

    func getNormalizedUsername(with font: UIFont) -> NSAttributedString {
        let anonymous = username.count == 0
        let name: String

        if isBanned {
            name = .tr("Banned")
        } else if anonymous {
            name = .tr("Anonymous")
        } else {
            name = username
            return NSAttributedString(string: name)
        }

        let attributes = [NSAttributedString.Key.font: font.withTraits(.traitItalic)]
        return NSAttributedString(string: name, attributes: attributes)
    }
}
