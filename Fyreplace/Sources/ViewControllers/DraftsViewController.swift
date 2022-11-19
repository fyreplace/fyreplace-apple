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
        [FPPost.draftWasCreatedNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPPost.draftWasUpdatedNotification]
    }

    override var removalNotifications: [Notification.Name] {
        [FPPost.draftWasDeletedNotification, FPPost.draftWasPublishedNotification]
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
               let position = tableView.indexPath(for: cell)?.row
            {
                draftController.post = vm.draft(at: position)
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
        (cell as? DraftTableViewCell)?.setup(withDraft: vm.draft(at: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "Draft", sender: tableView.cellForRow(at: indexPath))
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(
            style: .destructive,
            title: .tr("Delete")
        ) { [self] _, _, completion in
            let draft = vm.draft(at: indexPath.row)
            vm.delete(draft.id, at: indexPath.row, onCompletion: completion)
        }

        return .init(actions: [delete])
    }
}

extension DraftsViewController: DraftsViewModelDelegate {
    func draftsViewModel(_ viewModel: DraftsViewModel, didCreate id: Data) {
        NotificationCenter.default.post(
            name: FPPost.draftWasCreatedNotification,
            object: self,
            userInfo: ["item": FPPost.with { $0.id = id }]
        )

        DispatchQueue.main.async { [self] in
            createdPostId = id
            performSegue(withIdentifier: "Draft", sender: self)
        }
    }

    func draftsViewModel(_ viewModel: DraftsViewModel, didDelete id: Data, at position: Int, onCompletion handler: @escaping () -> Void) {
        NotificationCenter.default.post(
            name: FPPost.draftWasDeletedNotification,
            object: self,
            userInfo: ["item": vm.draft(at: position), "_completionHandler": handler]
        )
    }
}
