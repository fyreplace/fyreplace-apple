import ReactiveSwift
import UIKit

class ItemListViewController: DynamicTableViewController {
    @IBOutlet
    weak var listDelegate: ItemListViewDelegate!
    @IBOutlet
    var emptyPlaceholder: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl?.reactive.controlEvents(.valueChanged)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in onRefresh() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.disconnectionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserDisconnected($0) }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if viewIfLoaded?.window == nil {
            listDelegate.lister.reset()
            tableView.reloadData()
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.insert(item, at: indexPath.row)
        super.addItem(item, at: indexPath, becauseOf: reason)
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.update(item, at: indexPath.row)
        super.updateItem(item, at: indexPath, becauseOf: reason)
    }

    override func deleteItem(at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.remove(at: indexPath.row)
        super.deleteItem(at: indexPath, becauseOf: reason)
    }

    private func onRefresh() {
        listDelegate.lister.stopListing()
        listDelegate.lister.reset()
        tableView.reloadData()
        listDelegate.lister.startListing()
        listDelegate.lister.fetchMore()
    }

    private func onUserDisconnected(_ notification: Notification) {
        listDelegate.lister.reset()
        tableView.reloadData()
    }
}

extension ItemListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = listDelegate.lister.itemCount
        tableView.backgroundView = count == 0 ? emptyPlaceholder : nil
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
