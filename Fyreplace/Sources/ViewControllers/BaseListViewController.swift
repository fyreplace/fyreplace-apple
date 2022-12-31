import ReactiveSwift
import UIKit

class BaseListViewController: UITableViewController {
    open var additionNotifications: [Notification.Name] { [] }
    open var updateNotifications: [Notification.Name] { [] }
    open var removalNotifications: [Notification.Name] { [] }

    weak var listViewDelegate: BaseListViewDelegate!
    private var notificationTrash: [Disposable?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationHandlers()

        NotificationCenter.default.reactive
            .notifications(forName: UIApplication.willEnterForegroundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onApplicationWillEnterForeground($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIApplication.didEnterBackgroundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onApplicationDidEnterBackground($0) }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listViewDelegate.lister.startListing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        listViewDelegate.lister.stopListing()
        super.viewWillDisappear(animated)
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

        for removalNotification in removalNotifications {
            let disposable = NotificationCenter.default.reactive
                .notifications(forName: removalNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemRemoved($0) }
            notificationTrash.append(disposable)
        }
    }

    open func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    open func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    open func removeItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func onApplicationWillEnterForeground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        listViewDelegate.lister.startListing()
    }

    private func onApplicationDidEnterBackground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        listViewDelegate.lister.stopListing()
    }

    private func onItemAdded(_ notification: Notification) {
        guard let info = notification.userInfo,
              let item = info["item"]
        else { return }

        addItem(
            item,
            at: .init(row: 0, section: 0),
            becauseOf: notification
        )

        if let handler = info["_completionHandler"] as? (() -> Void) {
            handler()
        }
    }

    private func onItemUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let item = info["item"]
        else { return }

        let position = listViewDelegate.lister.getPosition(for: item)
        guard position != -1 else { return }

        updateItem(
            item,
            at: .init(row: position, section: 0),
            becauseOf: notification
        )

        if let handler = info["_completionHandler"] as? (() -> Void) {
            handler()
        }
    }

    private func onItemRemoved(_ notification: Notification) {
        guard let info = notification.userInfo,
              let item = info["item"]
        else { return }

        let position = listViewDelegate.lister.getPosition(for: item)
        guard position != -1 else { return }

        removeItem(
            item,
            at: .init(row: position, section: 0),
            becauseOf: notification
        )

        if let handler = info["_completionHandler"] as? (() -> Void) {
            handler()
        }
    }
}

@objc
protocol BaseListViewDelegate: NSObjectProtocol {
    var lister: BaseListerProtocol! { get }
}
