import Kingfisher
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder {
    static let didOpenUrlNotification = Notification.Name("AppDelegate.didOpenUrl")
    static let didChangeEnvironmentNotification = Notification.Name("AppDelegate.didChangeEnvironment")
    static let didUpdateRemoteNotificationTokenNotification = Notification.Name("AppDelegate.didUpdateRemoteNotificationToken")
    static let didReceiveRemoteNotificationNotification = Notification.Name("AppDelegate.didReceiveRemoteNotification")
    static let didOpenRemoteNotificationNotification = Notification.Name("AppDelegate.didOpenRemoteNotification")

    var window: UIWindow?
    var activityUrl: URL?

    func open(url: URL) {
        activityUrl = url
        NotificationCenter.default.post(name: Self.didOpenUrlNotification, object: self, userInfo: ["url": url])
    }

    private func firstTimeSetup() {
        guard !UserDefaults.standard.bool(forKey: "app:first-run") else { return }
        UserDefaults.standard.set(true, forKey: "app:first-run")
        _ = Keychain.authToken.delete()
    }
}

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        firstTimeSetup()

        for case let window? in application.windows + [window] {
            window.tintColor = .accent
        }

        if let remoteNotification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            NotificationCenter.default.post(
                name: Self.didOpenRemoteNotificationNotification,
                object: self,
                userInfo: remoteNotification
            )
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

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        KingfisherManager.shared.cache.clearMemoryCache()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(
            name: Self.didUpdateRemoteNotificationTokenNotification,
            object: self,
            userInfo: ["token": deviceToken.map { String(format: "%02x", $0) }.joined()]
        )
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let badge = userInfo["_aps.badge"] as? Int {
            application.applicationIconBadgeNumber = badge
        }

        guard let command = userInfo["_command"] as? String,
              let serializedComment = userInfo["comment"],
              let comment = try? FPComment(jsonUTF8Data: .init(jsonObject: serializedComment)),
              let postIdString = userInfo["postId"] as? String,
              let postId = Data(base64ShortString: postIdString)
        else { return completionHandler(.failed) }

        switch command {
        case "comment:creation":
            NotificationCenter.default.post(
                name: FPComment.wasCreatedNotification,
                object: self,
                userInfo: ["item": comment, "postId": postId]
            )

            if application.applicationState == .background {
                let content = makeUserNotificationContent(comment: comment, postId: postId, info: userInfo)
                createUserNotification(withIdentifier: comment.id.base64ShortString, withContent: content) {
                    completionHandler($0 == nil ? .noData : .failed)
                }
            }

        case "comment:deletion":
            NotificationCenter.default.post(
                name: FPComment.wasDeletedNotification,
                object: self,
                userInfo: ["item": comment, "postId": postId]
            )

            deleteUserNotifications {
                guard let nSerializedComment = $0.request.content.userInfo["comment"],
                      let nComment = try? FPComment(jsonUTF8Data: .init(jsonObject: nSerializedComment))
                else { return false }
                return nComment.id == comment.id
            } onCompletion: {
                completionHandler(.noData)
            }

        case "comment:acknowledgement":
            deleteUserNotifications {
                guard let nSerializedComment = $0.request.content.userInfo["comment"],
                      let nComment = try? FPComment(jsonUTF8Data: .init(jsonObject: nSerializedComment)),
                      let nPostIdString = $0.request.content.userInfo["postId"] as? String
                else { return false }
                return nPostIdString == postIdString && nComment.dateCreated.date <= comment.dateCreated.date
            } onCompletion: {
                completionHandler(.noData)
            }

        default:
            completionHandler(.noData)
        }

        NotificationCenter.default.post(
            name: Self.didReceiveRemoteNotificationNotification,
            object: self,
            userInfo: userInfo
        )
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            var options: UNNotificationPresentationOptions = [.badge, .banner, .sound]

            if notification.request.content.userInfo["_aps.list"] as? Bool != false {
                options.insert(.list)
            }

            completionHandler(options)
        } else {
            completionHandler([.badge, .alert, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let additionalInfo: [String: Any] = ["_completionHandler": completionHandler]
        NotificationCenter.default.post(
            name: Self.didOpenRemoteNotificationNotification,
            object: self,
            userInfo: response.notification.request.content.userInfo.merging(additionalInfo) { _, new in new }
        )
    }
}
