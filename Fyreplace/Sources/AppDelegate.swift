import UIKit

@main
class AppDelegate: UIResponder {
    static let urlOpenedNotification = Notification.Name("AppDelegate.urlOpened")
    var window: UIWindow?
    var activityUrl: URL?

    func open(url: URL) {
        activityUrl = url
        NotificationCenter.default.post(name: Self.urlOpenedNotification, object: self, userInfo: ["url": url])
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        for case let window? in application.windows + [window] {
            window.tintColor = .init(named: "AccentColor")
        }

        return true
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return userActivity.sendNotification()
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        open(url: url)
        return true
    }

    @available(iOS 13, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
