import ReactiveSwift
import UIKit

class ItemRandomAccessListViewController: BaseListViewController {
    @IBOutlet
    weak var listDelegate: ItemRandomAccessListViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        listViewDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if listDelegate.lister.itemCount == 0 {
            listDelegate.lister.fetch(around: 0)
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.insert(item)
        super.addItem(item, at: .init(row: listDelegate.lister.totalCount - 1, section: 0), becauseOf: reason)
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.update(item, at: indexPath.row)
        super.updateItem(item, at: indexPath, becauseOf: reason)
    }
}

extension ItemRandomAccessListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDelegate.lister.totalCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !listDelegate.itemRandomAccessListView(self, hasItemAtPosition: indexPath.row) {
            listDelegate.lister.fetch(around: indexPath.row)
        }

        let identifier = listDelegate.itemRandomAccessListView(self, itemPreviewTypeAtPosition: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
}

extension ItemRandomAccessListViewController: BaseListViewDelegate {
    var lister: BaseListerProtocol! { listDelegate.lister }
}

extension ItemRandomAccessListViewController: ItemRandomAccessListerDelegate {
    func itemRandomAccessLister(_ itemLister: ItemRandomAccessListerProtocol, didFetch count: Int, at position: Int, oldTotal: Int, newTotal: Int) {
        guard oldTotal != 0 else { return tableView.reloadData() }

        tableView.beginUpdates()
        defer { tableView.endUpdates() }

        if newTotal < oldTotal {
            tableView.deleteRows(at: .init(rows: newTotal ..< oldTotal, section: 0), with: .automatic)
        } else if newTotal > oldTotal {
            tableView.insertRows(at: .init(rows: oldTotal ..< newTotal, section: 0), with: .automatic)
        }

        tableView.reloadRows(at: .init(rows: position ..< position + count, section: 0), with: .automatic)
    }
}

@objc
protocol ItemRandomAccessListViewDelegate: NSObjectProtocol {
    var lister: ItemRandomAccessListerProtocol { get }

    func itemRandomAccessListView(_ listViewController: ItemRandomAccessListViewController, itemPreviewTypeAtPosition position: Int) -> String

    func itemRandomAccessListView(_ listViewController: ItemRandomAccessListViewController, hasItemAtPosition position: Int) -> Bool
}
