import GRPC
import UIKit

class UserViewController: UIViewController {
    @IBOutlet
    var vm: UserViewModel!
    @IBOutlet
    var menu: MenuBarButtonItem!
    @IBOutlet
    var block: ActionBarButtonItem!
    @IBOutlet
    var unblock: ActionBarButtonItem!
    @IBOutlet
    var report: ActionBarButtonItem!
    @IBOutlet
    var ban: ActionBarButtonItem!
    @IBOutlet
    var avatar: UIImageView!
    @IBOutlet
    var dateJoined: UILabel!
    @IBOutlet
    var bio: UITextView!
    @IBOutlet
    var dateFormat: DateFormat!

    var itemPosition: Int?
    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.blocked.value = profile.isBlocked
        vm.retrieve(id: profile.id)
        vm.user.producer.startWithValues { [weak self] in self?.onUser($0) }
        vm.blocked.producer.startWithValues { [weak self] in self?.onBlocked($0) }
        vm.banned.producer.startWithValues { [weak self] in self?.onBanned($0) }

        let isCurrentUser = profile.id == getCurrentProfile()?.id
        let currentRank = getCurrentProfile()?.rank ?? .unspecified
        report.isHidden = profile.rank != currentRank || isCurrentUser
        ban.isHidden = profile.rank >= currentRank || isCurrentUser
        menu.reload()

        navigationItem.title = profile.username
        avatar.setAvatar(profile.avatar.url)

        switch profile.rank {
        case .superuser:
            navigationItem.prompt = .tr("User.Rank.Superuser")

        case .staff:
            navigationItem.prompt = .tr("User.Rank.Staff")

        default: break
        }
    }

    @IBAction
    func onOkPressed() {
        navigationController?.dismiss(animated: true)
    }

    @IBAction
    func onBlockPressed() {
        presentChoiceAlert(text: "User.Block", dangerous: false) { self.vm.updateBlock(blocked: true) }
    }

    @IBAction
    func onUnblockPressed() {
        presentChoiceAlert(text: "User.Unblock", dangerous: false) { self.vm.updateBlock(blocked: false) }
    }

    @IBAction
    func onReportPressed() {
        presentChoiceAlert(text: "User.Report", dangerous: true) { self.vm.report() }
    }

    @IBAction
    func onBanPressed() {
        let alert = UIAlertController(
            title: .tr("User.Ban.Title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: .tr("User.Ban.Action.Week"), style: .default) { _ in
            self.vm.ban(for: .week)
        })
        alert.addAction(UIAlertAction(title: .tr("User.Ban.Action.Month"), style: .default) { _ in
            self.vm.ban(for: .month)
        })
        alert.addAction(UIAlertAction(title: .tr("User.Ban.Action.Permanently"), style: .destructive) { _ in
            self.presentChoiceAlert(text: .tr("User.Ban.Permanently"), dangerous: true) { self.vm.ban(for: .ever) }
        })
        alert.addAction(UIAlertAction(title: .tr("Cancel"), style: .cancel))
        present(alert, animated: true)
    }

    private func onUser(_ user: FPUser?) {
        guard let user = user else { return }
        let date = dateFormat.string(from: user.dateJoined.date)

        DispatchQueue.main.async { [self] in
            dateJoined.text = .localizedStringWithFormat(.tr("User.DateJoined"), date)
            bio.text = user.bio
        }
    }

    private func onBlocked(_ blocked: Bool) {
        let isCurrentUser = profile.id == getCurrentProfile()?.id
        block.isHidden = blocked || isCurrentUser
        unblock.isHidden = !blocked || isCurrentUser
        DispatchQueue.main.async { self.menu.reload() }
    }

    private func onBanned(_ banned: Bool) {
        ban.isHidden = banned
        DispatchQueue.main.async { self.menu.reload() }
    }
}

extension UserViewController: UserViewModelDelegate {
    func onBlockUpdate(_ blocked: Bool) {
        profile.isBlocked = blocked
        guard let position = itemPosition else { return }
        let notification = blocked
            ? BlockedUsersViewController.userBlockedNotification
            : BlockedUsersViewController.userUnblockedNotification
        let info: [String: Any] = ["position": position, "item": profile as Any]
        NotificationCenter.default.post(name: notification, object: self, userInfo: info)
    }

    func onReport() {
        presentBasicAlert(text: "User.Report.Success")
    }

    func onBan() {
        profile.isBanned = true
        presentBasicAlert(text: "User.Ban.Success")
        guard let position = itemPosition else { return }
        var info: [String: Any] = ["position": position]
        info["item"] = profile
        NotificationCenter.default.post(name: BlockedUsersViewController.userBannedNotification, object: self, userInfo: info)
    }

    func errorKey(for code: Int, with message: String?) -> String? {
        return "Error"
    }
}
