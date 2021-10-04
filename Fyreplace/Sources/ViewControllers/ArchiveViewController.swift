import UIKit

class ArchiveViewController: ListViewController {
    @IBOutlet
    var vm: ArchiveViewModel!
}

extension ArchiveViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)

        if let cell = cell as? PostTableViewCell {
            cell.setup(with: vm.post(atIndex: indexPath.row))
        }
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
