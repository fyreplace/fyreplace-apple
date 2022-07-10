import UIKit

class SceneDelegate: UIResponder {
    var window: UIWindow?

    @available(iOS 13.0, *)
    private func handle(urlContexts: Set<UIOpenURLContext>) {
        for context in urlContexts {
            UIApplication.shared.open(url: context.url)
        }
    }
}

@available(iOS 13, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window?.tintColor = .accent

        if let userActivity = connectionOptions.userActivities.first {
            _ = userActivity.sendNotification()
        } else {
            handle(urlContexts: connectionOptions.urlContexts)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = userActivity.sendNotification()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handle(urlContexts: URLContexts)
    }
}
