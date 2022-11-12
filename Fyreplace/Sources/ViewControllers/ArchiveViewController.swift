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

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        let path = reason.name == FPPost.draftWasPublishedNotification
            ? .init(row: 0, section: 0)
            : indexPath
        super.addItem(item, at: path, becauseOf: reason)
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
