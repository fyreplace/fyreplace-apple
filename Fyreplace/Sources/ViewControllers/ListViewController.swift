import ReactiveSwift
import UIKit

class ListViewController: UITableViewController {
    @IBOutlet
    weak var listDelegate: ListViewDelegate!
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

        NotificationCenter.default.reactive
            .notifications(forName: Self.additionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onItemAdded($0) }

        NotificationCenter.default.reactive
            .notifications(forName: Self.updateNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onItemUpdated($0) }

        NotificationCenter.default.reactive
            .notifications(forName: Self.deletionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onItemDeleted($0) }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        reset()
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
              let item = info["item"],
              info["changeHandled"] as? Bool != true
        else { return }

        listDelegate.lister.insert(item, at: position)
        tableView.insertRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
    }

    private func onItemUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let item = info["item"],
              info["changeHandled"] as? Bool != true
        else { return }

        listDelegate.lister.update(item, at: position)
        tableView.reloadRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
    }

    private func onItemDeleted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              info["changeHandled"] as? Bool != true
        else { return }

        listDelegate.lister.remove(at: position)
        tableView.deleteRows(at: [IndexPath(row: position, section: 0)], with: .automatic)
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
        tableView.insertRows(at: .init(rows: currentCount ..< currentCount + count, section: 0), with: .automatic)
    }
}

@objc
protocol ListViewDelegate: NSObjectProtocol {
    var lister: ItemListerProtocol { get }

    func itemPreviewType(atIndex index: Int) -> String
}
