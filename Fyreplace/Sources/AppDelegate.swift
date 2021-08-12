import UIKit

@main
class AppDelegate: UIResponder {
    static let urlOpenedNotification = Notification.Name("urlOpened")
    var window: UIWindow?
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = UIColor(named: "AccentColor")

        for window in application.windows {
            window.tintColor = UIColor(named: "AccentColor")
        }

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let userInfo = ["url": url]
        NotificationCenter.default.post(Notification(name: AppDelegate.urlOpenedNotification, userInfo: userInfo))
        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
