import SwiftUI

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
