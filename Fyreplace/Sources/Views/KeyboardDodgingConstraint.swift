import UIKit
import ReactiveSwift

public class KeyboardDodgingConstraint: NSLayoutConstraint {
    private var originalConstant: CGFloat?
    private var lastOrientation: UIDeviceOrientation?
    private var keyboardHeight: CGFloat = 0

    public override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: UIDevice.orientationDidChangeNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onOrientationDidChange($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIWindow.keyboardWillShowNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onKeyboardWillShow($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIWindow.keyboardWillHideNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onKeyboardWillHide($0) }
    }

    private func onOrientationDidChange(_ notification: Notification) {
        let currentOrientation = UIDevice.current.orientation
        guard currentOrientation != lastOrientation else { return }
        lastOrientation = currentOrientation

        if let original = originalConstant {
            constant = original
        }
    }

    private func onKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let frameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)
        guard let keyboardSize = frameValue?.cgRectValue.size else { return }

        if originalConstant == nil {
            originalConstant = constant
        }

        keyboardChanged(height: keyboardSize.height, info: userInfo)
    }

    private func onKeyboardWillHide(_ notification: Notification) {
        keyboardChanged(height: 0, info: notification.userInfo)
    }

    private func keyboardChanged(height: CGFloat, info: [AnyHashable: Any]?) {
        keyboardHeight = height
        constant = originalConstant! - keyboardHeight

        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let curve = info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber

        UIView.animate(
            withDuration: .init(duration?.doubleValue ?? TimeInterval(0.25)),
            delay: 0,
            options: .init(rawValue: curve?.uintValue ?? UInt(UIView.AnimationCurve.easeOut.rawValue)),
            animations: {
                for window in UIApplication.shared.windows {
                    window.layoutIfNeeded()
                }
            }
        )
    }
}
