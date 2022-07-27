import Foundation

extension FPUser {
    static let registrationEmailNotification = Notification.Name("FPUser.registrationEmail")
    static let connectionEmailNotification = Notification.Name("FPUser.connectionEmail")
    static let connectionNotification = Notification.Name("FPUser.connection")
    static let disconnectionNotification = Notification.Name("FPUser.disconnection")
    static let currentUserChangeNotification = Notification.Name("FPUser.currentUserChange")
    static let shouldReloadCurrentUserNotification = Notification.Name("FPUser.shouldReloadCurrentUser")
    static let blockNotification = Notification.Name("FPUser.block")
    static let unblockNotification = Notification.Name("FPUser.unblock")
    static let banNotification = Notification.Name("FPUser.ban")
}
