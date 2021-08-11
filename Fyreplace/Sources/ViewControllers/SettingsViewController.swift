import UIKit

class SettingsViewController: UITableViewController {}

extension SettingsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let loginViewController = segue.destination as? LoginViewController {
            loginViewController.isRegistering = segue.identifier == "Register"
        }
    }
}
