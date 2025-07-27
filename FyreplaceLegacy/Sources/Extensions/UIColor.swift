import UIKit

extension UIColor {
    static var labelCompat: UIColor {
        if #available(iOS 13, *) {
            return .label
        } else {
            return .black
        }
    }

    static var secondaryLabelCompat: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }

    static var placeholderTextCompat: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        } else {
            return .gray
        }
    }

    static var tintColorCompat: UIColor {
        if #available(iOS 15.0, *) {
            return .tintColor
        } else {
            return .accent
        }
    }
}
