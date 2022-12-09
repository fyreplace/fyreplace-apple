import UIKit

class BlockedUsersViewController: ItemListViewController {
    override var canBecomeFirstResponder: Bool { true }

    @IBOutlet
    var vm: BlockedUsersViewModel!
    @IBOutlet
    var edit: UIBarButtonItem!
    @IBOutlet
    var done: UIBarButtonItem!

    override var additionNotifications: [Notification.Name] {
        [FPUser.wasBlockedNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPUser.wasBannedNotification]
    }

    override var removalNotifications: [Notification.Name] {
        [FPUser.wasUnblockedNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "BlockedUserTableViewCell", bundle: nil), forCellReuseIdentifier: "BlockedUser")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let userNavigationController = segue.destination as? UserNavigationViewController,
           let cell = sender as? UITableViewCell,
           let position = tableView.indexPath(for: cell)?.row
        {
            userNavigationController.profile = vm.blockedUser(at: position)
        }
    }

    @IBAction
    func onEditPressed() {
        tableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = done
    }

    @IBAction
    func onDonePressed() {
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = edit
    }
}

extension BlockedUsersViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)
        edit.isEnabled = count > 0
        return count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        (cell as? BlockedUserTableViewCell)?.setup(withProfile: vm.blockedUser(at: indexPath.row))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        performSegue(withIdentifier: "User", sender: tableView.cellForRow(at: indexPath))
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let unblock = UIContextualAction(
            style: .destructive,
            title: .tr("BlockedUsers.Swipe.Unblock")
        ) { [self] _, _, completion in
            let profile = vm.blockedUser(at: indexPath.row)
            vm.unblock(userId: profile.id, at: indexPath.row, onCompletion: completion)
        }

        return .init(actions: [unblock])
    }
}

extension BlockedUsersViewController: BlockedUsersViewModelDelegate {
    func blockedUsersViewModel(_ viewModel: BlockedUsersViewModel, didUnblockAtPosition position: Int, onCompletion handler: @escaping () -> Void) {
        NotificationCenter.default.post(
            name: FPUser.wasUnblockedNotification,
            object: self,
            userInfo: ["item": vm.blockedUser(at: position), "_completionHandler": handler]
        )
    }
}
