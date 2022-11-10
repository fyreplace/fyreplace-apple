import Foundation

extension NSObjectProtocol {
    var currentUser: FPUser? { UserDefaults.standard.message(forKey: "auth:user") }
    var currentProfile: FPProfile? { currentUser?.profile }

    func setCurrentUser(_ user: FPUser?) {
        let connected: Bool

        if let user = user {
            connected = true
            UserDefaults.standard.set(user, forKey: "auth:user")
        } else {
            connected = false
            UserDefaults.standard.removeObject(forKey: "auth:user")
        }

        NotificationCenter.default.post(
            name: FPUser.currentDidChangeNotification,
            object: self,
            userInfo: ["connected": connected]
        )
    }
}
