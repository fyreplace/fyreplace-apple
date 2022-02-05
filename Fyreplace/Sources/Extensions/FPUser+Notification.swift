import Foundation

extension FPUser {
    static let userRegistrationEmailNotification = Notification.Name("FPUser.userRegistered")
    static let userConnectionEmailNotification = Notification.Name("FPUser.userRegistered")
    static let userConnectedNotification = Notification.Name("FPUser.userConnected")
    static let userDisconnectedNotification = Notification.Name("FPUser.userDisconnected")
    static let userChangedNotification = Notification.Name("FPUser.userChanged")
    static let shouldReloadUserNotification = Notification.Name("FPUser.shouldReloadUser")
}
