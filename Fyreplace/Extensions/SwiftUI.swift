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
#else
    extension UITextContentType {
        static var email: UITextContentType? {
            .emailAddress
        }
    }
#endif

extension View {
    func onDeepLink(perform action: @escaping (URL) -> Void) -> some View {
        return onOpenURL(perform: action)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) {
                if let url = $0.webpageURL {
                    action(url)
                }
            }
    }
}

extension Label where Title == Text, Icon == Image {
    init(_ destination: Destination) {
        self.init(destination.titleKey, systemImage: destination.icon)
    }
}
