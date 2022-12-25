import GRPC
import ReactiveSwift
import SDWebImage
import SwiftProtobuf
import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet
    var vm: SettingsViewModel!
    @IBOutlet
    var imageSelector: ImageSelector!
    @IBOutlet
    var avatar: UIImageView!
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var dateJoined: UILabel!
    @IBOutlet
    var email: UILabel!
    @IBOutlet
    var bio: UILabel!
    @IBOutlet
    var blockedUsers: UILabel!
    @IBOutlet
    var environments: [EnvironmentTableViewCell]!

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }

    private var canChangeEnvironment: Bool {
        if let hostKey = UserDefaults.standard.string(forKey: "app:environment"),
           hostKey != Bundle.main.apiDefaultHostKey
        {
            return true
        }

        return Bundle.main.bundleVersion.split(separator: ".").last == "0"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.sd_imageIndicator = SDWebImageActivityIndicator.medium
        avatar.sd_imageTransition = .fade
        avatar.reactive.isUserInteractionEnabled <~ vm.user.map { $0 != nil }
        username.reactive.text <~ vm.user.map { $0?.profile.username ?? .tr("Settings.Username") }
        dateJoined.reactive.text <~ vm.user.map(\.?.dateJoined).map { [weak self] dateJoined -> String in
            guard let dateJoined = dateJoined,
                  let dateFormatter = self?.dateFormatter
            else { return "" }
            return dateFormatter.string(from: dateJoined.date)
        }
        email.reactive.text <~ vm.user.map(\.?.email)
        bio.reactive.text <~ vm.user.map { ($0?.bio.count ?? 0) > 0 ? $0!.bio : .tr("Settings.Bio") }
        blockedUsers.reactive.text <~ vm.blockedUsers.map { String($0) }
        vm.user.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onUser($0) }

        let hostKey = UserDefaults.standard.string(forKey: "app:environment") ?? Bundle.main.apiDefaultHostKey

        for environment in environments {
            environment.accessoryType = environment.hostKey == hostKey ? .checkmark : .none
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let loginController = segue.destination as? LoginViewController {
            loginController.isRegistering = segue.identifier == "Register"
        }
    }

    @IBAction
    func onAvatarPressed() {
        imageSelector.selectImage(canRemove: vm.user.value?.profile.hasAvatar == true, fromView: avatar)
    }

    private func onUser(_ user: FPUser?) {
        DispatchQueue.main.async { self.avatar.setAvatar(from: user?.profile) }
        reloadTable()
    }

    private func reloadTable() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

extension SettingsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = super.numberOfSections(in: tableView)
        var omitted = 0

        if vm.user.value != nil {
            omitted = 2
        } else if !canChangeEnvironment {
            omitted = 1
        }

        return count - omitted
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Bundle.main.apiDefaultHostKey != Bundle.apiHostLocalKey,
           section == tableView.numberOfSections - 1,
           vm.user.value == nil,
           canChangeEnvironment
        {
            return super.tableView(tableView, numberOfRowsInSection: section) - 1
        }

        return shouldHide(section: section) ? 0 : super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? .leastNonzeroMagnitude : super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? .leastNonzeroMagnitude : super.tableView(tableView, heightForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return shouldHide(section: section) ? nil : super.tableView(tableView, titleForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return shouldHide(section: section) ? nil : super.tableView(tableView, titleForFooterInSection: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }

        switch cell.tag {
        case 2:
            changeEmail()

        case 11:
            URL(string: .tr("Legal.PrivacyPolicy.Url"))?.browse()

        case 12:
            URL(string: .tr("Legal.TermsOfService.Url"))?.browse()

        case 21:
            vm.logout()

        case 31:
            deleteAccount(from: cell)

        case 51, 52, 53:
            guard let cell = cell as? EnvironmentTableViewCell else { return }
            UserDefaults.standard.set(cell.hostKey, forKey: "app:environment")
            NotificationCenter.default.post(name: AppDelegate.didChangeEnvironmentNotification, object: self)

            for environment in environments {
                environment.accessoryType = environment == cell ? .checkmark : .none
            }

        default:
            return
        }
    }

    private func shouldHide(section: Int) -> Bool {
        guard section >= 0, section < tableView.numberOfSections else { return false }
        return (vm.user.value == nil) && (section < tableView.numberOfSections - (canChangeEnvironment ? 2 : 1))
    }

    private func changeEmail() {
        let alert = UIAlertController(
            title: .tr("Settings.EmailChange.Title"),
            message: .tr("Settings.EmailChange.Message"),
            preferredStyle: .alert
        )
        var newEmail = ""
        let update = UIAlertAction(title: .tr("Ok"), style: .default) { _ in
            self.vm.sendEmailUpdateEmail(email: newEmail)
        }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)

        alert.addTextField {
            $0.placeholder = .tr("Settings.EmailChange.TextField.Placeholder")
            $0.textContentType = .emailAddress
            $0.keyboardType = .emailAddress
            $0.returnKeyType = .done
            $0.reactive.continuousTextValues
                .take(during: $0.reactive.lifetime)
                .observeValues {
                    update.isEnabled = $0.count > 0
                    newEmail = $0
                }
        }
        alert.addAction(update)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    private func deleteAccount(from cell: UITableViewCell) {
        let alert = UIAlertController(
            title: .tr("Settings.AccountDeletion.Title"),
            message: .tr("Settings.AccountDeletion.Message"),
            preferredStyle: .actionSheet
        )
        let deleteText = String.tr("Settings.AccountDeletion.Action.Delete")
        let delete = UIAlertAction(title: deleteText, style: .destructive) { _ in
            self.vm.delete()
        }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)

        delete.isEnabled = false
        var secondsLeft = 3

        func count() {
            if secondsLeft > 0 {
                let text = String.tr("Settings.AccountDeletion.Action.Delete.Countdown")
                delete.setValue(String.localizedStringWithFormat(text, secondsLeft), forKey: "title")
                secondsLeft -= 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { count() }
            } else {
                delete.setValue(deleteText, forKey: "title")
                delete.isEnabled = true
            }
        }

        count()
        alert.addAction(delete)
        alert.addAction(cancel)

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = cell
        }

        present(alert, animated: true)
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func settingsViewModel(_ viewModel: SettingsViewModel, didUpdateAvatar url: String) {
        NotificationCenter.default.post(name: FPUser.currentShouldBeReloadedNotification, object: self)
    }

    func settingsViewModel(_ viewModel: SettingsViewModel, didSendEmailUpdateEmail email: String) {
        presentBasicAlert(text: "Settings.EmailChange.Success")
    }

    func settingsViewModelDidLogout(_ viewModel: SettingsViewModel) {
        reloadTable()
    }

    func settingsViewModelDidDelete(_ viewModel: SettingsViewModel) {
        reloadTable()
        presentBasicAlert(text: "Settings.AccountDeletion.Success")
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .alreadyExists:
            return "Login.Error.EmailAlreadyExists"

        case .invalidArgument:
            switch message {
            case "payload_too_large":
                return "ImageSelector.Error.Size"

            case "invalid_email":
                return "Login.Error.InvalidEmail"

            default:
                return "Error.Validation"
            }

        default:
            return "Error"
        }
    }
}

extension SettingsViewController: ImageSelectorDelegate {
    var maxImageByteSize: Int { 1024 * 1024 }

    func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: Data?) {
        vm.updateAvatar(image: image)
    }

    func didNotSelectImage(_ imageSelector: ImageSelector) {}
}
