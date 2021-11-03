import UIKit

class DynamicStackView: UIStackView {
    @IBOutlet
    weak var delegate: DynamicStackViewDelegate?

    override var bounds: CGRect {
        didSet { delegate?.boundsDidUpdate(bounds) }
    }
}

@objc
protocol DynamicStackViewDelegate {
    func boundsDidUpdate(_ bounds: CGRect)
}
