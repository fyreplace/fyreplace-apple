import UIKit

protocol NotificationTableViewCell {
    var count: UILabel! { get }

    func setup(withNotification notification: FPNotification)

    func setup(withCount count: UInt32, isFlag: Bool)
}

extension NotificationTableViewCell where Self: PostTableViewCell {
    func setup(withNotification notification: FPNotification) {
        setup(withPost: notification.post)
        setup(withCount: notification.count, isFlag: notification.isFlag)
    }
}

extension NotificationTableViewCell {
    func setup(withCount count: UInt32, isFlag: Bool) {
        self.count.text = String(count)
        self.count.textColor = isFlag ? .systemRed : .label
    }
}

class UserNotificationTableViewCell: ItemTableViewCell, NotificationTableViewCell {
    @IBOutlet
    var count: UILabel!

    func setup(withNotification notification: FPNotification) {
        setup(withProfile: notification.user)
        setup(withCount: notification.count, isFlag: notification.isFlag)
    }
}

class TextPostNotificationTableViewCell: TextPostTableViewCell, NotificationTableViewCell {
    @IBOutlet
    var count: UILabel!
}

class ImagePostNotificationTableViewCell: ImagePostTableViewCell, NotificationTableViewCell {
    @IBOutlet
    var count: UILabel!
}

class CommentNotificationTableViewCell: TextItemTableViewCell, NotificationTableViewCell {
    @IBOutlet
    var count: UILabel!

    func setup(withNotification notification: FPNotification) {
        setup(withProfile: notification.comment.author)
        setup(withText: notification.comment.text)
        setup(withCount: notification.count, isFlag: notification.isFlag)
    }
}
