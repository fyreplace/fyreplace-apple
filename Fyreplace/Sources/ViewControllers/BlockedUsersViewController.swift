import UIKit

class BlockedUsersViewController: ListViewController {
    @IBOutlet
    var vm: BlockedUsersViewModel!
}

extension BlockedUsersViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? BlockedUserTableViewCell else { return }
        cell.setup(with: vm.blockedUser(at: indexPath.row))
    }
}

extension BlockedUsersViewController: BlockedUsersViewModelDelegate {}
