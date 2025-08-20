import UIKit

extension UIBarButtonItem {
    func execute() {
        guard let action = action else { return }
        UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
    }
}
