import ReactiveSwift
import UIKit

class NotificationsViewController: ItemListViewController {
    @IBOutlet
    var vm: NotificationsViewModel!

    override var updateNotifications: [Notification.Name] {
        [FPNotification.updateNotification]
    }

    override var deletionNotifications: [Notification.Name] {
        [FPNotification.deletionNotification]
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPNotification.creationNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onNotificationCreation($0) }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let index = tableView.indexPathForSelectedRow?.row else { return }
        let notification = vm.notification(atIndex: index)

        switch (segue.destination, notification.target) {
        case let (controller as UserNavigationViewController, .user(profile)):
            controller.profile = profile

        case let (controller as PostViewController, .post(post)):
            controller.post = post

        case let (controller as PostViewController, .comment(comment)):
            controller.post = .with { $0.id = comment.id }
            controller.selectedComment = Int(comment.position)

        default:
            return
        }
    }

    private func onNotificationCreation(_ notification: Notification) {
        refreshListing()
    }
}

extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? NotificationTableViewCell)?.setup(withNotification: vm.notification(atIndex: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = vm.notification(atIndex: indexPath.row)
        guard notification.isFlag else { return nil }
        let dismiss = UIContextualAction(style: .destructive, title: .tr("Notifications.Item.Action.Dismiss")) { [self] _, _, _ in
            vm.absolve(notification: notification)
            deleteItem(notification, at: indexPath, becauseOf: .init(name: FPNotification.deletionNotification))
        }
        return UISwipeActionsConfiguration(actions: [dismiss])
    }
}

extension NotificationsViewController: NotificationsViewModelDelegate {
    func onAbsolveUser() {}

    func onAbsolvePost() {}

    func onAbsolveComment() {}
}
