import UIKit
import ReactiveSwift
import SDWebImage

class SettingsViewController: UITableViewController {
    @IBOutlet
    private var vm: SettingsViewModel!
    @IBOutlet
    private var avatar: UIImageView!
    @IBOutlet
    private var username: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.sd_imageTransition = .fade
        username.reactive.text <~ vm.user.map { $0?.username ?? .tr("Settings.Username") }
        vm.user.map(\.?.avatar.url).producer.start(onAvatarURLChanged(_:))
        vm.user.producer.start { [unowned self] _ in self.updateTable() }
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

    private func updateTable() {
        guard tableView.superview != nil else { return }
        let sections = IndexSet(integersIn: 0..<tableView.numberOfSections)
        tableView.reloadSections(sections, with: .automatic)
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
        let isLastSection = indexPath.section == numberOfSections(in: tableView) - 1
        guard vm.user.value != nil && isLastSection else { return }

        if indexPath.row == 0 {
            vm.logout()
        } else {
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
                    delete.setValue("\(deleteText) (\(secondsLeft))", forKey: "title")
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
}

extension SettingsViewController: SettingsViewModelDelegate {
    func onLogout() {
        reloadTable()
    }

    func onDelete() {
        reloadTable()
        presentBasicAlert(text: "Settings.AccountDeletion.Success")
    }

    func onFailure(_ error: Error) {
        presentBasicAlert(text: "Error", feedback: .error)
    }

    private func reloadTable() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}
