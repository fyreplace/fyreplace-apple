import UIKit

class ArchiveViewController: ListViewController {
    @IBOutlet
    var vm: ArchiveViewModel!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let postController = segue.destination as? PostViewController,
           let index = tableView.indexPathForSelectedRow?.row {
            postController.userId = vm.getUser()?.id
            postController.itemPosition = index
            postController.post = vm.post(atIndex: index)
        }
    }
}

extension ArchiveViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? PostTableViewCell else { return }
        cell.setup(with: vm.post(atIndex: indexPath.row))
    }
}

extension ArchiveViewController: ArchiveViewModelDelegate {}
