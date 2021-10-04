import UIKit

class ListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ListViewDelegate!
    @IBOutlet
    var emptyPlaceholder: UILabel!

    private var endReached = false

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundView = emptyPlaceholder
        refreshControl?.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    deinit {
        refreshControl?.removeTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        listDelegate.lister.startListing()

        if listDelegate.lister.itemCount == 0 {
            listDelegate.lister.fetchMore()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        listDelegate.lister.stopListing()
    }

    @objc
    private func onRefresh() {
        endReached = false
        listDelegate.lister.reset()
        tableView.reloadData()
        listDelegate.lister.fetchMore()
    }

    private func fetchMoreIfNeeded() {
        if !endReached {
            listDelegate.lister.fetchMore()
        }
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
        if listDelegate.lister.itemCount - indexPath.row == 1 {
            fetchMoreIfNeeded()
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

        if endReached {
            endReached = true
        }

        if tableView.visibleCells.count == listDelegate.lister.itemCount {
            fetchMoreIfNeeded()
        }
    }

    func onEnd() {
        endReached = true
    }
}

@objc
protocol ListViewDelegate: NSObjectProtocol {
    var lister: ItemListerProtocol { get }

    func itemPreviewType(atIndex index: Int) -> String
}
