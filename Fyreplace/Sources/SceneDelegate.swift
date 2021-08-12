import UIKit

class SceneDelegate: UIResponder {
    var window: UIWindow?
}

@available(iOS 13.0, *)
extension SceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        window?.tintColor = UIColor(named: "AccentColor")
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            let userInfo = ["url": context.url]
            NotificationCenter.default.post(Notification(name: AppDelegate.urlOpenedNotification, userInfo: userInfo))
        }
    }
}
