import ReactiveCocoa
import ReactiveSwift
import UIKit

@IBDesignable
class LargeFilledButton: UIButton {
    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize

        if #available(iOS 15, *) {
            return baseSize
        } else {
            return CGSize(width: baseSize.width + 24, height: baseSize.height)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        if #available(iOS 15, *) {
            return
        }

        layer.cornerRadius = 6
        let isEnabledSignal = reactive.signal(for: \.isEnabled)
        reactive.backgroundColor <~ isEnabledSignal.map {
            let disabled: UIColor

            if #available(iOS 13, *) {
                disabled = .secondarySystemBackground
            } else {
                disabled = .init(named: "ButtonBackgroundDisabledColor")!
            }

            return $0 ? .accent : disabled
        }
        reactive.tintColor <~ isEnabledSignal.map {
            let disabled: UIColor

            if #available(iOS 13, *) {
                disabled = .label
            } else {
                disabled = .black
            }

            return $0 ? .white : disabled
        }
    }
}
