import UserNotifications

func createUserNotification(withIdentifier identifier: String, withContent content: UNNotificationContent, onCompletion handler: ((Error?) -> Void)? = nil) {
    UNUserNotificationCenter.current().add(.init(
        identifier: identifier,
        content: content,
        trigger: nil
    )) { handler?($0) }
}

func deleteUserNotifications(where predicate: @escaping (UNNotification) -> Bool, onCompletion handler: (() -> Void)? = nil) {
    UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
        defer { handler?() }
        guard let notification = notifications.first(where: predicate) else { return }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
    }
}

func makeUserNotificationContent(comment: FPComment, postId: Data, info: [AnyHashable: Any]) -> UNMutableNotificationContent {
    let content = UNMutableNotificationContent()
    content.title = comment.author.username
    content.body = comment.text
    content.userInfo = info
    content.threadIdentifier = postId.base64ShortString

    if #available(iOS 15, *), let score = info["_aps.relevance-score"] as? Double {
        content.relevanceScore = score
    }

    return content
}
