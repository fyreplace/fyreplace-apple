import UIKit

class BlockedUsersViewController: ListViewController {
    override var canBecomeFirstResponder: Bool { true }

    @IBOutlet
    var vm: BlockedUsersViewModel!
    @IBOutlet
    var edit: UIBarButtonItem!
    @IBOutlet
    var done: UIBarButtonItem!

    override class var additionNotification: Notification.Name {
        Self.userBlockedNotification
    }

    override class var deletionNotification: Notification.Name {
        Self.userUnblockedNotification
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
        undoManager?.removeAllActions()
    }

    override func viewDidDisappear(_ animated: Bool) {
        resignFirstResponder()
        super.viewDidDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let userNavigationController = segue.destination as? UserNavigationViewController,
           let cell = sender as? BlockedUserTableViewCell,
           let index = tableView.indexPath(for: cell)?.row
        {
            userNavigationController.itemPosition = index
            userNavigationController.profile = vm.blockedUser(at: index)
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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? BlockedUserTableViewCell else { return }
        cell.setup(with: vm.blockedUser(at: indexPath.row))
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let profile = vm.blockedUser(at: indexPath.row)
        unblock(profile: profile, at: indexPath)
        setupUndo(for: profile, at: indexPath)
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return .tr("BlockedUsers.Swipe.Unblock")
    }

    private func block(profile: FPProfile, at indexPath: IndexPath) {
        vm.updateBlock(userId: profile.id, blocked: true, at: indexPath.row)
        vm.lister.insert(profile, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    private func unblock(profile: FPProfile, at indexPath: IndexPath) {
        vm.updateBlock(userId: profile.id, blocked: false, at: indexPath.row)
        vm.lister.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }

    private func setupUndo(for profile: FPProfile, at indexPath: IndexPath) {
        guard let undoer = undoManager else { return }
        undoer.setActionName(.tr("BlockedUsers.Swipe.Unblock"))
        undoer.registerUndo(withTarget: self) { [unowned undoer] target in
            target.block(profile: profile, at: indexPath)
            undoer.registerUndo(withTarget: target) { target in
                target.unblock(profile: profile, at: indexPath)
                target.setupUndo(for: profile, at: indexPath)
            }
        }
    }
}

extension BlockedUsersViewController: BlockedUsersViewModelDelegate {
    func onUpdateBlock(_ blocked: Bool, at index: Int) {
        NotificationCenter.default.post(
            name: blocked ? Self.userBlockedNotification : Self.userUnblockedNotification,
            object: self,
            userInfo: ["position": index, "changeHandled": true]
        )
    }
}
