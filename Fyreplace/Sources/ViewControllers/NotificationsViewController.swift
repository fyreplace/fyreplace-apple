import ReactiveSwift
import UIKit

class NotificationsViewController: ItemListViewController {
    @IBOutlet
    var vm: NotificationsViewModel!
    @IBOutlet
    var clear: UIBarButtonItem!

    override var updateNotifications: [Notification.Name] {
        [FPNotification.wasUpdatedNotification]
    }

    override var removalNotifications: [Notification.Name] {
        [FPNotification.wasDeletedNotification]
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPNotification.wasCreatedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onNotificationWasCreated($0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "UserNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "User")
        tableView.register(.init(nibName: "TextPostNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "Text Post")
        tableView.register(.init(nibName: "ImagePostNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "Image Post")
        tableView.register(.init(nibName: "CommentNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "Comment")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let cell = sender as? UITableViewCell,
              let position = tableView.indexPath(for: cell)?.row
        else { return }
        let notification = vm.notification(at: position)

        switch (segue.destination, notification.target) {
        case let (controller as UserNavigationViewController, .user(profile)):
            controller.profile = profile

        case let (controller as PostViewController, .post(post)):
            controller.post = post
            NotificationCenter.default.post(
                name: FPPost.wasSeenNotification,
                object: self,
                userInfo: ["item": post]
            )

        case let (controller as PostViewController, .comment(comment)):
            controller.post = .with { $0.id = comment.id }
            controller.selectedComment = Int(comment.position)

        default:
            return
        }
    }

    @IBAction
    func onClearPressed() {
        presentChoiceAlert(text: .tr("Notifications.Clear"), dangerous: true) { yes in
            guard yes else { return }
            self.vm.clear()
        }
    }

    private func onNotificationWasCreated(_ notification: Notification) {
        refreshListing()
    }
}

extension NotificationsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        clear.isEnabled = count > 0
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? NotificationTableViewCell)?.setup(withNotification: vm.notification(at: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = vm.notification(at: indexPath.row)
        guard notification.isFlag else { return nil }
        let dismiss = UIContextualAction(style: .destructive, title: .tr("Notifications.Item.Action.Dismiss")) { [self] _, _, completion in
            vm.absolve(at: indexPath.row, onCompletion: completion)
        }
        return .init(actions: [dismiss])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        switch tableView.cellForRow(at: indexPath) {
        case let cell as UserNotificationTableViewCell:
            performSegue(withIdentifier: "User", sender: cell)

        case let cell:
            performSegue(withIdentifier: "Post", sender: cell)
        }
    }
}

extension NotificationsViewController: NotificationsViewModelDelegate {
    func didClearNotifications(_ viewModel: NotificationsViewModel) {
        refreshListing()
    }

    func notificationsViewModel(_ viewModel: NotificationsViewModel, didAbsolve id: Data, at position: Int, onCompletion handler: @escaping () -> Void) {
        NotificationCenter.default.post(
            name: FPNotification.wasDeletedNotification,
            object: self,
            userInfo: ["item": vm.notification(at: position), "_completionHandler": handler]
        )
    }
}
