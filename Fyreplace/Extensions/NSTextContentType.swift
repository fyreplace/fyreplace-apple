import SwiftUI

#if os(macOS)
    extension NSTextContentType {
        static var email: NSTextContentType? {
            if #available(macOS 14.0, *) {
                .emailAddress
            } else {
                nil
            }
        }
    }
#endif
