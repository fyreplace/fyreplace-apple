import UIKit

extension UILabel {
    func setUsername(_ username: String) {
        let anonymous = username.count == 0
        let name = anonymous ? .tr("Anonymous") : username
        let attributes = anonymous ? [NSAttributedString.Key.font: font.withTraits(.traitItalic)] : nil
        attributedText = NSAttributedString(string: name, attributes: attributes)
    }
}
