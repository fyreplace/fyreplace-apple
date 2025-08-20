import Foundation

extension FPUser {
    static let currentDidSendRegistrationEmailNotification = Notification.Name("FPUser.currentDidSendRegistrationEmail")
    static let currentDidSendConnectionEmailNotification = Notification.Name("FPUser.currentDidSendConnectionEmail")
    static let currentDidConnectNotification = Notification.Name("FPUser.currentDidConnect")
    static let currentDidChangeNotification = Notification.Name("FPUser.currentDidChange")
    static let currentShouldBeReloadedNotification = Notification.Name("FPUser.currentShouldBeReloaded")
    static let wasBlockedNotification = Notification.Name("FPUser.wasBlocked")
    static let wasUnblockedNotification = Notification.Name("FPUser.wasUnblocked")
    static let wasBannedNotification = Notification.Name("FPUser.wasBanned")
}
