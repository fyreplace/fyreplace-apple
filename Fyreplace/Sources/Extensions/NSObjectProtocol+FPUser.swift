import Foundation

extension NSObjectProtocol {
    var currentUser: FPUser? { UserDefaults.standard.message(forKey: "auth:user") }
    var currentProfile: FPProfile? { currentUser?.profile }

    func setCurrentUser(_ user: FPUser?) {
        if let user = user {
            UserDefaults.standard.setValue(user, forKey: "auth:user")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth:user")
            NotificationCenter.default.post(name: FPUser.disconnectionNotification, object: self)
        }

        NotificationCenter.default.post(name: FPUser.currentUserChangeNotification, object: self)
    }
}
