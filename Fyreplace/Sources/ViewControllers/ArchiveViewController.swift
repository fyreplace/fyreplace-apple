import UIKit

class ArchiveViewController: ItemListViewController {
    @IBOutlet
    var vm: ArchiveViewModel!
    @IBOutlet
    var segments: UISegmentedControl!

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let postController = segue.destination as? PostViewController,
           let index = tableView.indexPathForSelectedRow?.row
        {
            postController.itemPosition = index
            postController.post = vm.post(atIndex: index)
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification.Name) {
        let path = reason == FPPost.draftPublicationNotification
            ? .init(row: 0, section: 0)
            : indexPath
        super.addItem(item, at: path, becauseOf: reason)
    }

    @IBAction
    private func onSegmentValueChanged() {
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
        (cell as? PostTableViewCell)?.setup(with: vm.post(atIndex: indexPath.row))
        return cell
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
