import ReactiveSwift
import UIKit

class ItemListViewController: BaseListViewController {
    @IBOutlet
    weak var listDelegate: ItemListViewDelegate!
    @IBOutlet
    var emptyPlaceholder: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        listViewDelegate = self

        refreshControl?.reactive.controlEvents(.valueChanged)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in onRefresh() }

        NotificationCenter.default.reactive
            .notifications(forName: UIApplication.didBecomeActiveNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onApplicationDidBecomeActive($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidChangeNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCurrentUserDidChange($0) }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fillIfEmpty()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        guard viewIfLoaded?.window == nil else { return }
        resetListing()
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.insert(item, at: indexPath.row)
        super.addItem(item, at: indexPath, becauseOf: reason)
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.update(item, at: indexPath.row)
        super.updateItem(item, at: indexPath, becauseOf: reason)
    }

    override func removeItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        listDelegate.lister.remove(at: indexPath.row)
        super.removeItem(item, at: indexPath, becauseOf: reason)
    }

    func resetListing() {
        listDelegate.lister.reset()
        tableView.reloadData()
    }

    func refreshListing() {
        DispatchQueue.main.async { [self] in
            listDelegate.lister.stopListing()
            resetListing()
            listDelegate.lister.startListing()
            listDelegate.lister.fetchMore()
        }
    }

    private func onRefresh() {
        refreshListing()
    }

    private func onApplicationDidBecomeActive(_ notification: Notification) {
        fillIfEmpty()
    }

    private func onCurrentUserDidChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let connected = info["connected"] as? Bool,
              !connected
        else { return }
        resetListing()
    }

    private func fillIfEmpty() {
        let manualCount = max(listDelegate.lister.manuallyAddedCount, 0)
        guard listDelegate.lister.itemCount - manualCount <= 0 else { return }
        resetListing()
        listDelegate.lister.fetchMore()
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

        let identifier = listDelegate.itemListView(self, itemPreviewTypeAtPosition: indexPath.row)
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemListViewController: ViewModelDelegate {
    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        return "Error"
    }
}

extension ItemListViewController: BaseListViewDelegate {
    var lister: BaseListerProtocol! { listDelegate.lister }
}

extension ItemListViewController: ItemListerDelegate {
    func itemLister(_ itemLister: ItemListerProtocol, didFetch count: Int) {
        if refreshControl?.isRefreshing == true {
            refreshControl?.endRefreshing()
        }

        let currentCount = tableView.numberOfRows(inSection: 0)
        tableView.insertRows(at: .init(rows: currentCount ..< currentCount + count, section: 0), with: .automatic)
    }
}

@objc
protocol ItemListViewDelegate: NSObjectProtocol {
    var lister: ItemListerProtocol { get }

    func itemListView(_ listViewController: ItemListViewController, itemPreviewTypeAtPosition position: Int) -> String
}
