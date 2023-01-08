import ReactiveSwift
import UIKit

class KeyboardDodgingConstraint: NSLayoutConstraint {
    private var originalConstant: CGFloat?
    private var lastOrientation: UIDeviceOrientation?
    private var keyboardHeight: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: UIDevice.orientationDidChangeNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onDeviceOrientationDidChange($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIWindow.keyboardWillShowNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onWindowKeyboardWillShow($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIWindow.keyboardDidHideNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onWindowKeyboardDidHide($0) }
    }

    private func onDeviceOrientationDidChange(_ notification: Notification) {
        let currentOrientation = UIDevice.current.orientation
        guard currentOrientation != lastOrientation else { return }
        lastOrientation = currentOrientation

        if let originalConstant {
            constant = originalConstant
        }
    }

    private func onWindowKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)
        else { return }
        let keyboardSize = frameValue.cgRectValue.size

        if originalConstant == nil {
            originalConstant = constant
        }

        keyboardChanged(height: keyboardSize.height, info: userInfo)
    }

    private func onWindowKeyboardDidHide(_ notification: Notification) {
        keyboardChanged(height: 0, info: notification.userInfo)
    }

    private func keyboardChanged(height: CGFloat, info: [AnyHashable: Any]?) {
        keyboardHeight = height
        constant = originalConstant! + keyboardHeight

        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let curve = info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber

        UIView.animate(
            withDuration: duration?.doubleValue ?? 0.25,
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
