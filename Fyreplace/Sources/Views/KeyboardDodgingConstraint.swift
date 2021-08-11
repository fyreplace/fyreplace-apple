import UIKit

public class KeyboardDodgingConstraint: NSLayoutConstraint {
    private var originalConstant: CGFloat?
    private var lastOrientation: UIDeviceOrientation?
    private var keyboardHeight: CGFloat = 0

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func onOrientationDidChange(_ notification: Notification) {
        let currentOrientation = UIDevice.current.orientation
        guard currentOrientation != lastOrientation else { return }
        lastOrientation = currentOrientation

        if let original = originalConstant {
            constant = original
        }
    }

    @objc
    private func onKeyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let frameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)
        guard let keyboardSize = frameValue?.cgRectValue.size else { return }

        if originalConstant == nil {
            originalConstant = constant
        }

        keyboardChanged(height: keyboardSize.height, info: userInfo)
    }

    @objc
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
