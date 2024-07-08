import SwiftUI

#if !os(macOS)
    extension UITextContentType {
        static var email: UITextContentType? {
            .emailAddress
        }
    }
#endif
