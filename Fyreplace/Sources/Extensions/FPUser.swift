import Foundation

extension FPUser {
    static let userRegisteredNotification = Notification.Name("userRegistered")
    static let userConnectedNotification = Notification.Name("userConnected")
    static let userDisconnectedNotification = Notification.Name("userDisconnected")
    static let userChangedNotification = Notification.Name("userChanged")
    static let shouldReloadUserNotification = Notification.Name("shouldReloadUser")
}
