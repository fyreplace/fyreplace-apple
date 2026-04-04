import Combine
import UIKit

class KeyboardDodgingConstraint: NSLayoutConstraint {
    private var originalConstant: CGFloat?
    private var lastOrientation: UIDeviceOrientation?
    private var cancellables: Set<AnyCancellable>?

    override func awakeFromNib() {
        super.awakeFromNib()
        cancellables = []

        NotificationCenter.default
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onDeviceOrientationDidChange($0) }
            .store(in: &cancellables!)

        NotificationCenter.default
            .publisher(for: UIWindow.keyboardDidShowNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onWindowKeyboardShow($0) }
            .store(in: &cancellables!)

        NotificationCenter.default
            .publisher(for: UIWindow.keyboardWillHideNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onWindowKeyboardHide($0) }
            .store(in: &cancellables!)
    }

    private func onDeviceOrientationDidChange(_ notification: Notification) {
        let currentOrientation = UIDevice.current.orientation
        guard currentOrientation != lastOrientation else { return }
        lastOrientation = currentOrientation

        if let originalConstant {
            constant = originalConstant
        }
    }

    private func onWindowKeyboardShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)
        else { return }
        let keyboardSize = frameValue.cgRectValue.size

        if originalConstant == nil {
            originalConstant = constant
        }

        keyboardChanged(height: keyboardSize.height, info: userInfo)
    }

    private func onWindowKeyboardHide(_ notification: Notification) {
        keyboardChanged(height: 0, info: notification.userInfo)
    }

    private func keyboardChanged(height: CGFloat, info: [AnyHashable: Any]?) {
        let totalHeight = abs(originalConstant!) + height

        if let firstView = firstItem as? UIView,
           let secondView = secondItem as? UIView,
           firstView.superview == secondView {
            constant = -totalHeight
        } else {
            constant = totalHeight
        }

        let duration = info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        let curve = info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber

        UIView.animate(
            withDuration: duration?.doubleValue ?? 0.25,
            delay: 0,
            options: .init(rawValue: curve?.uintValue ?? UInt(UIView.AnimationCurve.easeOut.rawValue)),
            animations: {
                for window in UIApplication.shared.sceneWindows {
                    window.layoutIfNeeded()
                }
            }
        )
    }
}
