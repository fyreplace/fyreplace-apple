import UIKit
import ReactiveSwift

class ListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ListViewDelegate!
    @IBOutlet
    var emptyPlaceholder: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyPlaceholder
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        NotificationCenter.default.reactive
            .notifications(forName: Self.itemDeletedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onItemDeleted($0) }
    }

    deinit {
        refreshControl?.removeTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listDelegate.lister.startListing()

        if listDelegate.lister.itemCount == 0 {
            listDelegate.lister.fetchMore()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listDelegate.lister.stopListing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        reset()
    }

    @objc
    private func onRefresh() {
        reset()
        listDelegate.lister.fetchMore()
    }

    private func onItemDeleted(_ notification: Notification) {
        guard let itemPosition = notification.userInfo?["itemPosition"] as? Int else { return }
        listDelegate.lister.remove(at: itemPosition)
        tableView.deleteRows(at: [IndexPath(row: itemPosition, section: 0)], with: .automatic)
    }

    private func reset() {
        listDelegate.lister.reset()
        tableView.reloadData()
    }
}

extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = listDelegate.lister.itemCount
        tableView.backgroundView?.isHidden = count > 0
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = listDelegate.itemPreviewType(atIndex: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if listDelegate.lister.itemCount - indexPath.row < listDelegate.lister.pageSize {
            listDelegate.lister.fetchMore()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ListViewController: ViewModelDelegate {
    func onFailure(_ error: Error) {
        presentBasicAlert(text: "Error", feedback: .error)
    }
}

extension ListViewController: ItemListerDelegate {
    func onFetch(count: Int) {
        if refreshControl?.isRefreshing ?? false {
            refreshControl?.endRefreshing()
        }

        let currentCount = tableView.numberOfRows(inSection: 0)
        let indexPaths = (currentCount..<currentCount + count).map { IndexPath(row: $0, section: 0) }
        tableView.insertRows(at: indexPaths, with: .automatic)
    }
}

@objc
protocol ListViewDelegate: NSObjectProtocol {
    var lister: ItemListerProtocol { get }

    func itemPreviewType(atIndex index: Int) -> String
}
