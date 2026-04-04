import Combine
import UIKit

class BaseListViewController: UITableViewController {
    open var additionNotifications: [Notification.Name] { [] }
    open var updateNotifications: [Notification.Name] { [] }
    open var removalNotifications: [Notification.Name] { [] }

    weak var listViewDelegate: BaseListViewDelegate!
    private var cancellables = Set<AnyCancellable>()
    private var refreshableCancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshNotificationHandlers()

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onApplicationWillEnterForeground($0) }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onApplicationDidEnterBackground($0) }
            .store(in: &cancellables)
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
        refreshableCancellables.removeAll()

        for additionNotification in additionNotifications {
            NotificationCenter.default
                .publisher(for: additionNotification)
                .receive(on: RunLoop.main)
                .sink { [unowned self] in onItemAdded($0) }
                .store(in: &refreshableCancellables)
        }

        for updateNotification in updateNotifications {
            NotificationCenter.default
                .publisher(for: updateNotification)
                .receive(on: RunLoop.main)
                .sink { [unowned self] in onItemUpdated($0) }
                .store(in: &refreshableCancellables)
        }

        for removalNotification in removalNotifications {
            NotificationCenter.default
                .publisher(for: removalNotification)
                .receive(on: RunLoop.main)
                .sink { [unowned self] in onItemRemoved($0) }
                .store(in: &refreshableCancellables)
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
