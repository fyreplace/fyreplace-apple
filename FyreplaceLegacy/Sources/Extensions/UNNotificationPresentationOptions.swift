import UserNotifications

extension UNNotificationPresentationOptions {
    static var `default`: Self {
        [.badge, .sound, .banner]
    }
}
