import UIKit

@IBDesignable
class RoundImageView: UIImageView {
    override var frame: CGRect { didSet { setupView() } }
    override var bounds: CGRect { didSet { setupView() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        let size = min(bounds.width, bounds.height)
        layer.cornerRadius = size / 2
    }
}
