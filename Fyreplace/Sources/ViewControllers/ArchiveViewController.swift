import UIKit

class ArchiveViewController: ItemListViewController {
    @IBOutlet
    var vm: ArchiveViewModel!

    override class var additionNotification: Notification.Name {
        Self.postAddedNotification
    }

    override class var deletionNotification: Notification.Name {
        Self.postDeletedNotification
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

    @IBAction
    private func onSegmentValueChanged(_ sender: UISegmentedControl) {
        listDelegate.lister.stopListing()
        vm.toggleLister(toOwn: sender.selectedSegmentIndex > 0)
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
