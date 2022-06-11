import Foundation

extension FPUser {
    static let userRegistrationEmailNotification = Notification.Name("FPUser.userRegistrationEmail")
    static let userConnectionEmailNotification = Notification.Name("FPUser.userConnectionEmail")
    static let userConnectedNotification = Notification.Name("FPUser.userConnected")
    static let userDisconnectedNotification = Notification.Name("FPUser.userDisconnected")
    static let userChangedNotification = Notification.Name("FPUser.userChanged")
    static let shouldReloadUserNotification = Notification.Name("FPUser.shouldReloadUser")
}
