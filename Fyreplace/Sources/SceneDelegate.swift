import UIKit

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

@available(iOS 13.0, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window?.tintColor = UIColor(named: "AccentColor")
        guard let userActivity = connectionOptions.userActivities.first else { return }
        _ = userActivity.sendNotification()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = userActivity.sendNotification()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            NotificationCenter.default.post(name: AppDelegate.urlOpenedNotification, object: self, userInfo: ["url": context.url])
        }
    }
}
