import UserNotifications

func createUserNotification(withIdentifier identifier: String, withContent content: UNNotificationContent, onCompletion handler: ((Error?) -> Void)? = nil) {
    UNUserNotificationCenter.current().add(.init(
        identifier: identifier,
        content: content,
        trigger: nil
    )) { handler?($0) }
}

func deleteUserNotifications(where predicate: @escaping (UNNotificationRequest) -> Bool, onCompletion handler: (() -> Void)? = nil) {
    let center = UNUserNotificationCenter.current()
    var deliveredDeleted = false
    var pendingDeleted = false

    func tryHandler() {
        guard deliveredDeleted, pendingDeleted else { return }
        handler?()
    }

    center.getDeliveredNotifications { notifications in
        center.removeDeliveredNotifications(withIdentifiers: notifications.map(\.request).filter(predicate).map(\.identifier))
        deliveredDeleted = true
        tryHandler()
    }

    center.getPendingNotificationRequests { requests in
        center.removePendingNotificationRequests(withIdentifiers: requests.filter(predicate).map(\.identifier))
        pendingDeleted = true
        tryHandler()
    }
}

func makeUserNotificationContent(comment: FPComment, postId: Data, info: [AnyHashable: Any]) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = comment.author.username
    content.body = comment.text
    content.userInfo = info
    content.threadIdentifier = postId.base64ShortString

    if let score = info["_aps.relevance-score"] as? Double {
        content.relevanceScore = score
    }

    return content
}
