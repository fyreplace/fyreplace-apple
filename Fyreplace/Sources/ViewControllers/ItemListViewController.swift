import ReactiveSwift
import UIKit

class ItemListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ItemListViewDelegate!
    @IBOutlet
    var emptyPlaceholder: UILabel!

    open class var additionNotification: Notification.Name? { nil }
    open class var updateNotification: Notification.Name? { nil }
    open class var deletionNotification: Notification.Name? { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyPlaceholder
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userDisconnectedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserDisconnected($0) }

        if let additionNotification = Self.additionNotification {
            NotificationCenter.default.reactive
                .notifications(forName: additionNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemAdded($0) }
        }

        if let updateNotification = Self.updateNotification {
            NotificationCenter.default.reactive
                .notifications(forName: updateNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemUpdated($0) }
        }

        if let deletionNotification = Self.deletionNotification {
            NotificationCenter.default.reactive
                .notifications(forName: deletionNotification)
                .take(during: reactive.lifetime)
                .observe(on: UIScheduler())
                .observeValues { [unowned self] in onItemDeleted($0) }
        }
    }

    deinit {
        refreshControl?.removeTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDelegate.lister.startListing()

        if listDelegate.lister.itemCount == 0 {
            listDelegate.lister.fetchMore()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listDelegate.lister.stopListing()
    }

    func addItem(_ item: Any, at indexPath: IndexPath) {
        listDelegate.lister.insert(item, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    func updateItem(_ item: Any, at indexPath: IndexPath) {
        listDelegate.lister.update(item, at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func deleteItem(at indexPath: IndexPath) {
        listDelegate.lister.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    @objc
    private func onRefresh() {
        reset()
        listDelegate.lister.fetchMore()
    }

    private func onUserDisconnected(_ notification: Notification) {
        reset()
    }

    private func onItemAdded(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"]
        else { return }

        addItem(item, at: IndexPath(row: position, section: 0))
    }

    private func onItemUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"]
        else { return }

        updateItem(item, at: IndexPath(row: position, section: 0))
    }

    private func onItemDeleted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int
        else { return }

        deleteItem(at: IndexPath(row: position, section: 0))
    }

    private func reset() {
        listDelegate.lister.reset()
        tableView.reloadData()
    }
}

extension ItemListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = listDelegate.lister.itemCount
        tableView.backgroundView?.isHidden = count > 0
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if listDelegate.lister.itemCount - indexPath.row < listDelegate.lister.pageSize {
            listDelegate.lister.fetchMore()
        }

        let identifier = listDelegate.itemPreviewType(atIndex: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemListViewController: ViewModelDelegate {
    func errorKey(for code: Int, with message: String?) -> String? {
        return "Error"
    }
}

extension ItemListViewController: ItemListerDelegate {
    func onFetch(count: Int) {
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }

        let currentCount = tableView.numberOfRows(inSection: 0)
        tableView.insertRows(at: .init(rows: currentCount ..< currentCount + count, section: 0), with: .automatic)
    }
}

@objc
protocol ItemListViewDelegate: NSObjectProtocol {
    var lister: ItemListerProtocol { get }

    func itemPreviewType(atIndex index: Int) -> String
}
