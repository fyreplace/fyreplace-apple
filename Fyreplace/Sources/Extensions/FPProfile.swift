import UIKit

extension FPProfile {
    var isAvailable: Bool { !isBanned && !username.isEmpty }

    func getNormalizedUsername(with font: UIFont?) -> NSAttributedString {
        let isAnonymous = username.count == 0
        let name: String
        var isNormalName = false

        if isDeleted {
            name = .tr("Profile.Deleted")
        } else if isBanned {
            name = .tr("Profile.Banned")
        } else if isAnonymous {
            name = .tr("Profile.Anonymous")
        } else {
            name = username
            isNormalName = true
        }

        let attributes: [NSAttributedString.Key: Any]?

        if let font = font, !isNormalName {
            attributes = [NSAttributedString.Key.font: font.withTraits(.traitItalic)]
        } else {
            attributes = nil
        }

        return NSAttributedString(string: name, attributes: attributes)
    }
}
