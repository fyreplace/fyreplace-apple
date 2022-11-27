import GRPC
import SDWebImage
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

    var profile: FPProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.medium
        avatar.sd_imageTransition = .fade
        vm.blocked.value = profile.isBlocked
        vm.retrieve(id: profile.id)
        vm.user.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onUser($0) }
        vm.blocked.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onBlocked($0) }
        vm.banned.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onBanned($0) }

        let isCurrentUser = profile.id == currentProfile?.id
        let currentRank = currentProfile?.rank ?? .unspecified
        report.isConcealed = profile.rank != currentRank || isCurrentUser
        ban.isConcealed = profile.rank >= currentRank || isCurrentUser
        menu.reload()

        navigationItem.title = profile.getNormalizedUsername(with: nil).string
        avatar.setAvatar(from: profile)

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

    @IBAction
    func onBanPressed() {
        let alert = UIAlertController(
            title: .tr("User.Ban.Title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(
            title: .tr("User.Ban.Action.Week"),
            style: .default
        ) { _ in self.vm.ban(for: .week) })
        alert.addAction(UIAlertAction(
            title: .tr("User.Ban.Action.Month"),
            style: .default
        ) { _ in self.vm.ban(for: .month) })
        alert.addAction(UIAlertAction(
            title: .tr("User.Ban.Action.Permanently"),
            style: .destructive
        ) { _ in
            self.presentChoiceAlert(text: .tr("User.Ban.Permanently"), dangerous: true) { yes in
                guard yes else { return }
                self.vm.ban(for: .ever)
            }
        })
        alert.addAction(UIAlertAction(title: .tr("Cancel"), style: .cancel))
        present(alert, animated: true)
    }

    private func onUser(_ user: FPUser?) {
        guard let user = user else { return }
        let date = dateFormat.string(from: user.dateJoined.date)

        DispatchQueue.main.async { [self] in
            self.dateJoined.text = .localizedStringWithFormat(.tr("User.DateJoined"), date)
            self.bio.text = user.bio
        }
    }

    private func onBlocked(_ blocked: Bool) {
        let isCurrentUser = profile.id == currentProfile?.id
        block.isConcealed = blocked || isCurrentUser
        unblock.isConcealed = !blocked || isCurrentUser
        DispatchQueue.main.async { self.menu.reload() }
    }

    private func onBanned(_ banned: Bool) {
        if banned {
            report.isConcealed = true
            ban.isConcealed = true
        }

        DispatchQueue.main.async { self.menu.reload() }
    }
}

extension UserViewController: UserViewModelDelegate {
    func userViewModel(_ viewModel: UserViewModel, didUpdate id: Data, blocked: Bool) {
        profile.isBlocked = blocked
        NotificationCenter.default.post(
            name: blocked ? FPUser.wasBlockedNotification : FPUser.wasUnblockedNotification,
            object: self,
            userInfo: ["item": profile!]
        )
    }

    func userViewModel(_ viewModel: UserViewModel, didReport id: Data) {
        presentBasicAlert(text: "User.Report.Success")
    }

    func userViewModel(_ viewModel: UserViewModel, didBan id: Data) {
        profile.isBanned = true
        presentBasicAlert(text: "User.Ban.Success")
        NotificationCenter.default.post(
            name: FPUser.wasBannedNotification,
            object: self,
            userInfo: ["item": profile!]
        )
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        return "Error"
    }
}
