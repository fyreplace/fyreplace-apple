import UIKit

@IBDesignable
class BaseCommentTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    func setupView() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
    }
}
