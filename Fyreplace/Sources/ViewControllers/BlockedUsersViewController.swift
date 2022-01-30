import UIKit

class BlockedUsersViewController: ListViewController {
    @IBOutlet
    var vm: BlockedUsersViewModel!

    override class var additionNotification: Notification.Name {
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let profile = vm.blockedUser(at: indexPath.row)
        let unblockAction = UIContextualAction(
            style: .destructive,
            title: .tr("BlockedUsers.Swipe.Unblock")
        ) { [unowned self] action, view, completion in
            presentChoiceAlert(text: "User.Unblock", dangerous: false) { yes in
                guard yes else { return completion(false) }
                vm.unblock(userId: profile.id, at: indexPath.row)
            }
        }

        return UISwipeActionsConfiguration(actions: [unblockAction])
    }
}

extension BlockedUsersViewController: BlockedUsersViewModelDelegate {
    func onUnblock(at index: Int) {
        DispatchQueue.main.async { [self] in
            vm.lister.remove(at: index)
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }

        NotificationCenter.default.post(
            name: Self.userUnblockedNotification,
            object: self,
            userInfo: ["position": index]
        )
    }
}
