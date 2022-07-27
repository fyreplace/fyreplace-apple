import ReactiveSwift
import UIKit

class ItemRandomAccessListViewController: DynamicTableViewController {
    @IBOutlet
    weak var listDelegate: ItemRandomAccessListViewDelegate!

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

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        listDelegate.lister.insert(item)
        super.addItem(item, at: .init(row: listDelegate.lister.totalCount - 1, section: 0), becauseOf: reason)
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        listDelegate.lister.update(item, at: indexPath.row)
        super.updateItem(item, at: indexPath, becauseOf: reason)
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
