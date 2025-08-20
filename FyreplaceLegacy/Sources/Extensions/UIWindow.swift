import SwiftUI
import UIKit

extension UIWindow {
    func launchNextVersion() {
        rootViewController = UIHostingController(rootView: EnvironmentView(eventBus: EventBus()))
    }
}
