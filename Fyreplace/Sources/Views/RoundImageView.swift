import UIKit

@IBDesignable
class RoundImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        clipsToBounds = true
        let size = min(bounds.width, bounds.height)
        layer.cornerRadius = size / 2
    }
}
