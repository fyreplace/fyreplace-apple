import UIKit
import ReactiveSwift
import ReactiveCocoa

@IBDesignable
class LargeFilledButton: UIButton {
    override var intrinsicContentSize: CGSize {
        let baseSize = super.intrinsicContentSize

        if #available(iOS 15.0, *) {
            return baseSize
        }

        return CGSize(width: baseSize.width + 24, height: baseSize.height)
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
        if #available(iOS 15.0, *) {
            return
        }

        layer.cornerRadius = 6
        let isEnabledSignal = reactive.signal(for: \.isEnabled)
        reactive.backgroundColor <~ isEnabledSignal.map {
            let disabled: UIColor

            if #available(iOS 13.0, *) {
                disabled = .secondarySystemBackground
            } else {
                disabled = .init(named: "ButtonBackgroundDisabledColor")!
            }

            return $0 ? .init(named: "AccentColor")! : disabled
        }
        reactive.tintColor <~ isEnabledSignal.map {
            let disabled: UIColor

            if #available(iOS 13.0, *) {
                disabled = .label
            } else {
                disabled = .black
            }

            return $0 ? .white : disabled
        }
    }
}
