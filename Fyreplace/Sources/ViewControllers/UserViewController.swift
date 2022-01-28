import UIKit
import GRPC

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
        navigationItem.title = profile.username
        report.isHidden = profile.rank > FPRank.citizen || profile.id == getCurrentProfile()?.id
        menu.reload()
        avatar.sd_imageTransition = .fade
        avatar.setAvatar(profile.avatar.url)

        let prompt: String?

        switch profile.rank {
        case .superuser:
            prompt = "User.Rank.Superuser"

        case .staff:
            prompt = "User.Rank.Staff"

        default:
            prompt = nil
        }

        if let prompt = prompt {
            navigationItem.prompt = .tr(prompt)
        }
    }

    @IBAction
    func onOkPressed() {
        navigationController?.dismiss(animated: true)
    }

    @IBAction
    func onBlockPressed() {
        presentChoiceAlert(text: "User.Block", dangerous: false) { yes in
            guard yes else { return }
            self.vm.updateBlock(blocked: true)
        }
    }

    @IBAction
    func onUnblockPressed() {
        presentChoiceAlert(text: "User.Unblock", dangerous: false) { yes in
            guard yes else { return }
            self.vm.updateBlock(blocked: false)
        }
    }

    @IBAction
    func onReportPressed() {
        presentChoiceAlert(text: "User.Report", dangerous: true) { yes in
            guard yes else { return }
            self.vm.report()
        }
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
}

extension UserViewController: UserViewModelDelegate {
    func onBlockUpdate(_ blocked: Bool) {
        guard let position = itemPosition else { return }
        let notification = blocked
            ? BlockedUsersViewController.userBlockedNotification
            : BlockedUsersViewController.userUnblockedNotification
        var info: [String: Any] = ["position": position]

        if blocked {
            info["item"] = profile
        }

        NotificationCenter.default.post(name: notification, object: self, userInfo: info)
    }

    func onReport() {
        presentBasicAlert(text: "User.Report")
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }
}
