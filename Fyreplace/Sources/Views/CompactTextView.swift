import UIKit

@IBDesignable
class CompactTextView: LinkTextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    override func setup() {
        super.setup()
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }
}
