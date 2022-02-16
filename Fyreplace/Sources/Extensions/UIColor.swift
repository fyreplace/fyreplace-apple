import UIKit

extension UIColor {
    static var labelCompat: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
}
