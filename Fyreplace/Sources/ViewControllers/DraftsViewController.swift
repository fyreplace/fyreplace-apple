import ReactiveCocoa
import ReactiveSwift
import UIKit

class DraftsViewController: ItemListViewController {
    @IBOutlet
    var vm: DraftsViewModel!
    @IBOutlet
    var add: UIBarButtonItem!
    @IBOutlet
    var loader: UIActivityIndicatorView!

    private var createdPostId = Data()

    override var additionNotifications: [Notification.Name] {
        [FPPost.draftCreationNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPPost.draftUpdateNotification]
    }

    override var deletionNotifications: [Notification.Name] {
        [FPPost.draftDeletionNotification, FPPost.draftPublicationNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        add.reactive.isEnabled <~ vm.isLoading.negate()
        loader.reactive.isAnimating <~ vm.isLoading
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let draftController = segue.destination as? DraftViewController {
            if let cell = sender as? UITableViewCell,
               let index = tableView.indexPath(for: cell)?.row
            {
                draftController.itemPosition = index
                draftController.post = vm.post(atIndex: index)
            } else {
                draftController.itemPosition = 0
                draftController.post = .with { $0.id = createdPostId }
            }
        }
    }

    @IBAction
    func onAddPressed() {
        vm.create()
    }
}

extension DraftsViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? PostTableViewCell)?.setup(with: vm.post(atIndex: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        vm.delete(vm.post(atIndex: indexPath.row).id)
        deleteItem(at: indexPath, becauseOf: FPPost.draftDeletionNotification)
    }
}

extension DraftsViewController: DraftsViewModelDelegate {
    func onCreate(_ id: Data) {
        NotificationCenter.default.post(
            name: FPPost.draftCreationNotification,
            object: self,
            userInfo: ["position": 0, "item": FPPost.with { $0.id = id }]
        )

        DispatchQueue.main.async { [self] in
            createdPostId = id
            performSegue(withIdentifier: "Add", sender: self)
        }
    }

    func onDelete() {}
}
