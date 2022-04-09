import UIKit

class DraftsViewController: ItemListViewController {
    @IBOutlet
    var vm: DraftsViewModel!
}

extension DraftsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? PostTableViewCell {
            cell.setup(with: vm.post(atIndex: indexPath.row))
        }

        return cell
    }
}
