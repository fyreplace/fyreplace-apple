import UIKit

extension UIView {
    func cropToCircle() {
        let size = min(bounds.width, bounds.height)
        layer.cornerRadius = size / 2
    }
}
