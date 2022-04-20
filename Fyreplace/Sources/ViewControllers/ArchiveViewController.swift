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
}

extension ArchiveViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? PostTableViewCell {
            cell.setup(with: vm.post(atIndex: indexPath.row))
        }

        return cell
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
