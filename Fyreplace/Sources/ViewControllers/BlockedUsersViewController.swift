import UIKit

class BlockedUsersViewController: ListViewController {
    @IBOutlet
    var vm: BlockedUsersViewModel!

    override class var additionNotification: Notification.Name? {
        Self.userBlockedNotification
    }
    override class var deletionNotification: Notification.Name {
        Self.userUnblockedNotification
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let userNavigationController = segue.destination as? UserNavigationViewController,
           let cell = sender as? BlockedUserTableViewCell,
           let index = tableView.indexPath(for: cell)?.row {
            userNavigationController.itemPosition = index
            userNavigationController.profile = vm.blockedUser(at: index)
        }
    }
}

extension BlockedUsersViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? BlockedUserTableViewCell else { return }
        cell.setup(with: vm.blockedUser(at: indexPath.row))
    }
}

extension BlockedUsersViewController: BlockedUsersViewModelDelegate {}
