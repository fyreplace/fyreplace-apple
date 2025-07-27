import UIKit

extension UIApplicationShortcutItem {
    func run(on window: UIWindow) {
        switch self.type {
        case "app.fyreplace.Fyreplace.next-version": window.launchNextVersion()
        default: break
        }
    }
}
