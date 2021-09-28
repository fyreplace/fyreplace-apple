import Foundation

extension NSObjectProtocol {
    func getUser() -> FPUser? {
        return UserDefaults.standard.message(forKey: "auth:user")
    }

    func setUser(_ user: FPUser?) {
        if let user = user {
            UserDefaults.standard.setValue(user, forKey: "auth:user")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth:user")
        }

        NotificationCenter.default.post(name: FPUser.userChangedNotification, object: self)
    }
}
