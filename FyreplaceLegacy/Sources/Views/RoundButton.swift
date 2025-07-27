import UIKit

@IBDesignable
class RoundButton: UIButton {
    override var frame: CGRect { didSet { cropToCircle() } }
    override var bounds: CGRect { didSet { cropToCircle() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        cropToCircle()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        cropToCircle()
    }
}
