import UserNotifications

extension UNNotificationPresentationOptions {
    static var `default`: Self {
        var options: UNNotificationPresentationOptions = [.badge, .sound]

        if #available(iOS 14, *) {
            options.insert(.banner)
        } else {
            options.insert(.alert)
        }

        return options
    }
}
