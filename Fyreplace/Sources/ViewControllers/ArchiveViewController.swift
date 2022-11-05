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

    private var isListingAllPosts: Bool { segments.selectedSegmentIndex == 0 }

    override var additionNotifications: [Notification.Name] {
        isListingAllPosts
            ? [FPPost.draftPublicationNotification, FPPost.subscriptionNotification]
            : [FPPost.draftPublicationNotification]
    }

    override var deletionNotifications: [Notification.Name] {
        isListingAllPosts
            ? [FPPost.deletionNotification, FPPost.unsubscriptionNotification]
            : [FPPost.deletionNotification]
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
           let index = tableView.indexPath(for: cell)?.row
        {
            postController.post = vm.post(atIndex: index)
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        let path = reason.name == FPPost.draftPublicationNotification
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
        (cell as? PostTableViewCell)?.setup(withPost: vm.post(atIndex: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "Post", sender: tableView.cellForRow(at: indexPath))
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
