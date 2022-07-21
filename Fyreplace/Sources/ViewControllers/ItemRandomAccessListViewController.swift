import ReactiveSwift
import UIKit

class ItemRandomAccessListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ItemRandomAccessListViewDelegate!

    open class var additionNotification: Notification.Name? { nil }
    open class var updateNotification: Notification.Name? { nil }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listDelegate.lister.startListing()

        if listDelegate.lister.itemCount == 0 {
            listDelegate.lister.fetch(around: 0)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listDelegate.lister.stopListing()
    }

    func addItem(_ item: Any) {
        listDelegate.lister.insert(item)
        tableView.insertRows(
            at: [.init(row: listDelegate.lister.totalCount - 1, section: 0)],
            with: .automatic
        )
    }

    func updateItem(_ item: Any, at indexPath: IndexPath) {
        listDelegate.lister.update(item, at: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func onItemAdded(_ notification: Notification) {
        guard let info = notification.userInfo,
              let item = info["item"]
        else { return }

        addItem(item)
    }

    private func onItemUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"]
        else { return }

        updateItem(item, at: IndexPath(row: position, section: 0))
    }
}

extension ItemRandomAccessListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDelegate.lister.totalCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !listDelegate.hasItem(atIndex: indexPath.row) {
            listDelegate.lister.fetch(around: indexPath.row)
        }

        let identifier = listDelegate.itemPreviewType(atIndex: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}

extension ItemRandomAccessListViewController: ItemRandomAccessListerDelegate {
    func onFetch(count: Int, at index: Int) {
        if tableView.numberOfRows(inSection: 0) == 0 {
            tableView.reloadSections(.init(integer: 0), with: .automatic)
        } else {
            tableView.reloadRows(at: .init(rows: index ..< index + count, section: 0), with: .automatic)
        }
    }
}

@objc
protocol ItemRandomAccessListViewDelegate: NSObjectProtocol {
    var lister: ItemRandomAccessListerProtocol { get }

    func itemPreviewType(atIndex index: Int) -> String

    func hasItem(atIndex index: Int) -> Bool
}
