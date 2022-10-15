import UIKit

extension UIColor {
    static var labelCompat: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }

    static var secondaryLabelCompat: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }

    static var placeholderTextCompat: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return .gray
        }
    }

    static var accent: UIColor {
        return .init(named: "AccentColor")!
    }
}
