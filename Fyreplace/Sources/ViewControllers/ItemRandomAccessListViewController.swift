import UIKit

class ItemRandomAccessListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ItemRandomAccessListViewDelegate!
}

extension ItemRandomAccessListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDelegate.lister.totalCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = listDelegate.itemPreviewType(atIndex: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !listDelegate.hasItem(atIndex: indexPath.row) {
            listDelegate.lister.fetch(at: indexPath.row - indexPath.row % Int(listDelegate.lister.pageSize))
        }
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
