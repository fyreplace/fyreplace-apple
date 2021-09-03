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

    @IBAction
    private func onLogoutSelected() {
        vm.logout()
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
        if vm.user.value != nil && indexPath.section == numberOfSections(in: tableView) - 1 {
            tableView.deselectRow(at: indexPath, animated: true)
            vm.logout()
        }
    }
}

extension SettingsViewController: SettingsViewModelDelegate {
    func onLogout() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func onFailure(_ error: Error) {
        presentBasicAlert(text: "Error", feedback: .error)
    }
}
