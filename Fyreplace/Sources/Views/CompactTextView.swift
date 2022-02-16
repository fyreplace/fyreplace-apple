import UIKit

@IBDesignable
class CompactTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    private func setup() {
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }
}
