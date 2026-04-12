import Combine
import GRPC
import UIKit

class LoginViewController: UITableViewController {
    @IBOutlet
    var vm: LoginViewModel!
    @IBOutlet
    var email: UITextField!
    @IBOutlet
    var username: UITextField!
    @IBOutlet
    var buttonLabel: UILabel!
    @IBOutlet
    var buttonContainer: UITableViewCell!
    @IBOutlet
    var loader: UIActivityIndicatorView!

    var isRegistering = true
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.isRegistering = isRegistering

        vm.$isLoading
            .receive(on: RunLoop.main)
            .assign(to: \.isHidden, on: buttonLabel)
            .store(in: &cancellables)
        vm.$isLoading
            .receive(on: RunLoop.main)
            .sink { [unowned self] in
                if $0 {
                    loader.startAnimating()
                } else {
                    loader.stopAnimating()
                }
            }
            .store(in: &cancellables)
        vm.canProceedPublisher
            .map { $0 ? .tintColor : .secondaryLabel }
            .receive(on: RunLoop.main)
            .assign(to: \.textColor, on: buttonLabel)
            .store(in: &cancellables)
        vm.canProceedPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isUserInteractionEnabled, on: buttonContainer)
            .store(in: &cancellables)

        navigationItem.title = .tr("Login." + (isRegistering ? "Register" : "Login"))
        email.returnKeyType = isRegistering ? .next : .done
        buttonLabel.text = navigationItem.title
    }

    @IBAction
    func onEmailEditingChanged() {
        vm.email = email.text ?? ""
    }

    @IBAction
    func onEmailDidEndOnExit() {
        if isRegistering {
            username.becomeFirstResponder()
        } else {
            email.resignFirstResponder()
        }
    }

    @IBAction
    func onUsernameEditingChanged() {
        vm.username = username.text ?? ""
    }

    @IBAction
    func onUsernameDidEndOnExit() {
        username.resignFirstResponder()
    }

    @IBAction
    func onConditionsAcceptedValueChanged(_ sender: UISwitch) {
        vm.conditionsAccepted = sender.isOn
    }
    
    private func askPassword() {
        let alert = UIAlertController(
            title: .tr("Login.Password.Title"),
            message: nil,
            preferredStyle: .alert
        )
        var password = ""
        var cancellable: AnyCancellable?
        let ok = UIAlertAction(title: .tr("Ok"), style: .default) { _ in
            self.vm.login(with: password)
            cancellable?.cancel()
        }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel) { _ in
            cancellable?.cancel()
        }

        alert.addTextField {
            $0.textContentType = .password
            $0.returnKeyType = .done
            $0.isSecureTextEntry = true
            cancellable = $0.textPublisher
                .compactMap(\.self)
                .sink {
                    ok.isEnabled = $0.count > 0
                    password = $0
                }
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension LoginViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldHide(section: section) {
            return 0
        } else if !isRegistering, section == 0 {
            return 1
        }

        return super.tableView(tableView, numberOfRowsInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? 0 : super.tableView(tableView, heightForHeaderInSection: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return shouldHide(section: section) ? 0 : super.tableView(tableView, heightForFooterInSection: section)
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

        switch cell.accessibilityIdentifier {
        case "PrivacyPolicy":
            URL(string: .tr("Legal.PrivacyPolicy.Url"))?.browse()

        case "TermsOfService":
            URL(string: .tr("Legal.TermsOfService.Url"))?.browse()

        case "Submit":
            if isRegistering {
                vm.register()
            } else {
                vm.login()
            }

        default:
            return
        }
    }

    private func shouldHide(section: Int) -> Bool {
        return !isRegistering && section == 1
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func loginViewModel(_ viewModel: LoginViewModel, didRegisterWithEmail email: String, andUsername username: String) {
        NotificationCenter.default.post(
            name: FPUser.currentDidSendRegistrationEmailNotification,
            object: self
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func loginViewModel(_ viewModel: LoginViewModel, didLoginWithPassword withPassword: Bool) {
        NotificationCenter.default.post(
            name: withPassword
                ? FPUser.currentDidConnectNotification
                : FPUser.currentDidSendConnectionEmailNotification,
            object: self
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .cancelled:
            DispatchQueue.main.async { self.askPassword() }
            return nil

        case .notFound:
            return "Login.Error.EmailNotFound"

        case .alreadyExists:
            return "Login.Error.\(message == "email_taken" ? "Email" : "Username")AlreadyExists"

        case .permissionDenied:
            return ["caller_pending", "caller_deleted", "caller_banned", "username_reserved"].contains(message)
                ? "Login.Error.\(message!.pascalized)"
                : "Error.Permission"

        case .invalidArgument:
            return ["invalid_credentials", "invalid_email", "invalid_username", "invalid_password"].contains(message)
                ? "Login.Error.\(message!.pascalized)"
                : "Error.Validation"

        default:
            return "Error"
        }
    }
}
