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
        tableView.register(.init(nibName: "EmptyDraftTableViewCell", bundle: nil), forCellReuseIdentifier: "Empty")
        tableView.register(.init(nibName: "TextDraftTableViewCell", bundle: nil), forCellReuseIdentifier: "Text")
        tableView.register(.init(nibName: "ImageDraftTableViewCell", bundle: nil), forCellReuseIdentifier: "Image")
        add.reactive.isEnabled <~ vm.isLoading.negate()
        loader.reactive.isAnimating <~ vm.isLoading
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let draftController = segue.destination as? DraftViewController {
            if let cell = sender as? UITableViewCell,
               let index = tableView.indexPath(for: cell)?.row
            {
                draftController.post = vm.post(atIndex: index)
            } else {
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
        (cell as? DraftTableViewCell)?.setup(withDraft: vm.post(atIndex: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let post = vm.post(atIndex: indexPath.row)
        vm.delete(post.id)
        deleteItem(post, at: indexPath, becauseOf: .init(name: FPPost.draftDeletionNotification))
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "Draft", sender: tableView.cellForRow(at: indexPath))
    }
}

extension DraftsViewController: DraftsViewModelDelegate {
    func onCreate(_ id: Data) {
        NotificationCenter.default.post(
            name: FPPost.draftCreationNotification,
            object: self,
            userInfo: ["item": FPPost.with { $0.id = id }]
        )

        DispatchQueue.main.async { [self] in
            createdPostId = id
            performSegue(withIdentifier: "Draft", sender: self)
        }
    }

    func onDelete() {}
}
