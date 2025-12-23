import UIKit

@IBDesignable
class TextInputTextView: UITextView {
    @IBInspectable
    var textPadding: CGFloat = 20 { didSet { padText() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        padText()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        padText()
    }

    private func padText() {
        textContainerInset.left = textPadding
        textContainerInset.right = textPadding
    }
}
