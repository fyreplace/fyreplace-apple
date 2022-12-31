import ReactiveSwift
import UIKit

class ArchiveViewController: ItemListViewController {
    @IBOutlet
    var vm: ArchiveViewModel!
    @IBOutlet
    var segments: UISegmentedControl!
    @IBOutlet
    var archiveEmptyPlaceholder: UILabel!
    @IBOutlet
    var ownPostsEmptyPlaceholder: UILabel!
    @IBOutlet
    var dateFormat: DateFormat!

    private var isListingAllPosts: Bool { segments.selectedSegmentIndex == 0 }

    override var additionNotifications: [Notification.Name] {
        isListingAllPosts
            ? [FPPost.draftWasPublishedNotification, FPPost.wasSubscribedToNotification]
            : [FPPost.draftWasPublishedNotification]
    }

    override var removalNotifications: [Notification.Name] {
        isListingAllPosts
            ? [FPPost.wasDeletedNotification, FPPost.wasUnsubscribedFromNotification]
            : [FPPost.wasDeletedNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "TextPostTableViewCell", bundle: nil), forCellReuseIdentifier: "Text")
        tableView.register(.init(nibName: "ImagePostTableViewCell", bundle: nil), forCellReuseIdentifier: "Image")

        NotificationCenter.default.reactive
            .notifications(forName: FPPost.wasSeenNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onPostWasSeen($0) }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let postController = segue.destination as? PostViewController,
           let cell = sender as? UITableViewCell,
           let position = tableView.indexPath(for: cell)?.row
        {
            postController.post = vm.post(at: position)
        }
    }

    @IBAction
    private func onSegmentValueChanged() {
        emptyPlaceholder = isListingAllPosts ? archiveEmptyPlaceholder : ownPostsEmptyPlaceholder
        listDelegate.lister.stopListing()
        vm.toggleLister(toOwn: !isListingAllPosts)
        refreshNotificationHandlers()
        tableView.reloadData()
        listDelegate.lister.startListing()
        listDelegate.lister.fetchMore()
    }

    private func onPostWasSeen(_ notification: Notification) {
        guard let info = notification.userInfo,
              let item = info["item"]
        else { return }

        let position = listDelegate.lister.getPosition(for: item)

        if position != -1 {
            removeItem(item, at: .init(row: position, section: 0), becauseOf: notification)
        }

        addItem(item, at: .init(row: 0, section: 0), becauseOf: notification)
    }
}

extension ArchiveViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? ItemTableViewCell)?.dateFormat = dateFormat
        (cell as? PostTableViewCell)?.setup(withPost: vm.post(at: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "Post", sender: tableView.cellForRow(at: indexPath))
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
