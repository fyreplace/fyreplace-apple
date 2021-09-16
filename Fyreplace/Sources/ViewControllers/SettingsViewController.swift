import UIKit
import ReactiveSwift
import SwiftProtobuf
import GRPC
import SDWebImage

class SettingsViewController: UITableViewController {
    @IBOutlet
    private var vm: SettingsViewModel!
    @IBOutlet
    private var avatar: UIImageView!
    @IBOutlet
    private var username: UILabel!
    @IBOutlet
    private var dateJoined: UILabel!
    @IBOutlet
    private var email: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.sd_imageTransition = .fade
        username.reactive.text <~ vm.user.map { $0?.username ?? .tr("Settings.Username") }
        vm.user.map(\.?.avatar.url).producer.start(onAvatarURLChanged(_:))
        vm.user.map(\.?.dateJoined).producer.start(onDateJoinedChanged(_:))
        vm.user.map(\.?.email).producer.start(onEmailChanged(_:))
        vm.user.producer.start { [unowned self] _ in reloadTable() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let loginViewController = segue.destination as? LoginViewController {
            loginViewController.isRegistering = segue.identifier == "Register"
        }
    }

    private func onAvatarURLChanged(_ event: Signal<String?, Never>.Event) {
        let defaultImage = UIImage(called: "person.crop.circle")

        if let url = event.value ?? nil {
            avatar.sd_setImage(with: URL(string: url), placeholderImage: defaultImage)
        } else {
            avatar.image = defaultImage
        }
    }

    private func onDateJoinedChanged(_ event: Signal<Google_Protobuf_Timestamp?, Never>.Event) {
        if let timestamp = event.value ?? nil {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            dateJoined.text = formatter.string(from: timestamp.date)
        } else {
            dateJoined.text = nil
        }
    }

    private func onEmailChanged(_ event: Signal<String?, Never>.Event) {
        email.text = event.value ?? nil
    }
}

extension SettingsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return vm.user.value != nil ? super.numberOfSections(in: tableView) - 1 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rowCount = vm.user.value != nil ? section + 1 : section
        return super.tableView(tableView, numberOfRowsInSection: rowCount)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section + (vm.user.value != nil ? 1 : 0)
        let path = IndexPath(row: indexPath.row, section: section)
        return super.tableView(tableView, cellForRowAt: path)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard vm.user.value != nil else { return }

        switch indexPath {
        case .init(row: 1, section: 0):
            changeEmail()

        case .init(row: 0, section: 1):
            vm.logout()

        case .init(row: 1, section: 1):
            deleteAccount()

        default:
            return
        }
    }

    private func changeEmail() {
        let alert = UIAlertController(title: .tr("Settings.EmailChange.Title"), message: .tr("Settings.EmailChange.Message"), preferredStyle: .alert)
        var newEmail: UITextField?
        let update = UIAlertAction(title: .tr("Ok"), style: .default) { [unowned self] _ in
            guard let address = newEmail?.text else { return }
            vm.sendEmailUpdateEmail(address: address)
        }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)

        alert.addTextField {
            newEmail = $0
            $0.placeholder = .tr("Settings.EmailChange.TextField.Placeholder")
            $0.textContentType = .emailAddress
            $0.keyboardType = .emailAddress
            $0.reactive.continuousTextValues.observeValues { update.isEnabled = $0.count > 0 }
        }
        alert.addAction(update)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    private func deleteAccount() {
        let alert = UIAlertController(title: .tr("Settings.AccountDeletion.Title"), message: .tr("Settings.AccountDeletion.Message"), preferredStyle: .actionSheet)
        let deleteText = String.tr("Settings.AccountDeletion.Action.Delete")
        let delete = UIAlertAction(title: deleteText, style: .destructive) { [unowned self] _ in
            vm.delete()
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
        present(alert, animated: true)
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func onSendEmailUpdateEmail() {
        presentBasicAlert(text: "Settings.EmailChange.Success")
    }

    func onLogout() {
        reloadTable()
    }

    func onDelete() {
        reloadTable()
        presentBasicAlert(text: "Settings.AccountDeletion.Success")
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        case .alreadyExists:
            key = "Login.Error.ExistingEmail"

        case .invalidArgument:
            key = "Login.Error.InvalidEmail"

        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }

    private func reloadTable() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
