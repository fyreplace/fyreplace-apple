import Foundation

extension NSObjectProtocol {
    func getCurrentUser() -> FPUser? {
        return UserDefaults.standard.message(forKey: "auth:user")
    }

    func setCurrentUser(_ user: FPUser?) {
        if let user = user {
            UserDefaults.standard.setValue(user, forKey: "auth:user")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth:user")
            NotificationCenter.default.post(name: FPUser.userDisconnectedNotification, object: self)
        }

        NotificationCenter.default.post(name: FPUser.userChangedNotification, object: self)
    }
}
