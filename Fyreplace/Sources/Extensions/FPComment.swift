import UIKit

extension FPComment {
    func getNormalizedText(with font: UIFont?) -> NSAttributedString {
        let content = isDeleted ? .tr("Comment.Deleted") : text
        let attributes: [NSAttributedString.Key: Any]?

        if let font = font {
            attributes = [NSAttributedString.Key.font: isDeleted ? font.withTraits(.traitItalic) : font]
        } else {
            attributes = nil
        }

        return NSAttributedString(string: content, attributes: attributes)
    }
}
