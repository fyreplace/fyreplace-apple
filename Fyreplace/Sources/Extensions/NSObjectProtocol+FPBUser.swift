import Foundation

extension NSObjectProtocol {
    func getUser() -> FPBUser? {
        return UserDefaults.standard.message(forKey: "auth:user")
    }

    func setUser(_ user: FPBUser?) {
        if let user = user {
            UserDefaults.standard.setValue(user, forKey: "auth:user")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth:user")
        }

        NotificationCenter.default.post(name: FPBUser.userChangedNotification, object: self)
    }
}
