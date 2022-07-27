import ReactiveSwift
import UIKit

class DynamicTableViewController: UITableViewController {
    open var additionNotifications: [Notification.Name] { [] }
    open var updateNotifications: [Notification.Name] { [] }
    open var deletionNotifications: [Notification.Name] { [] }

    private var notificationTrash: [Disposable?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationHandlers()
    }

    func refreshNotificationHandlers() {
        for disposable in notificationTrash {
            disposable?.dispose()
        }

        notificationTrash.removeAll()

        for additionNotification in additionNotifications {
            let disposable = NotificationCenter.default.reactive
                .notifications(forName: additionNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemAdded($0) }
            notificationTrash.append(disposable)
        }

        for updateNotification in updateNotifications {
            let disposable = NotificationCenter.default.reactive
                .notifications(forName: updateNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemUpdated($0) }
            notificationTrash.append(disposable)
        }

        for deletionNotification in deletionNotifications {
            let disposable = NotificationCenter.default.reactive
                .notifications(forName: deletionNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemDeleted($0) }
            notificationTrash.append(disposable)
        }
    }

    open func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    open func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    open func deleteItem(at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func onItemAdded(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"]
        else { return }

        addItem(
            item,
            at: IndexPath(row: position, section: 0),
            becauseOf: notification.name
        )
    }

    private func onItemUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"]
        else { return }

        updateItem(
            item,
            at: IndexPath(row: position, section: 0),
            becauseOf: notification.name
        )
    }

    private func onItemDeleted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int
        else { return }

        deleteItem(
            at: IndexPath(row: position, section: 0),
            becauseOf: notification.name
        )
    }
}
