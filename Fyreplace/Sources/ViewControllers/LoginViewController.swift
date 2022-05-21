import GRPC
import ReactiveCocoa
import ReactiveSwift
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet
    var vm: LoginViewModel!
    @IBOutlet
    var email: UITextField!
    @IBOutlet
    var username: UITextField!
    @IBOutlet
    var button: UIButton!
    @IBOutlet
    var loader: UIActivityIndicatorView!
    @IBOutlet
    var privacyPolicy: UIButton!
    @IBOutlet
    var termsOfService: UIButton!

    public var isRegistering = true

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.isRegistering.value = isRegistering
        vm.email <~ email.reactive.continuousTextValues
        vm.username <~ username.reactive.continuousTextValues
        button.reactive.isEnabled <~ vm.canProceed
        button.reactive.isHidden <~ vm.isLoading
        loader.reactive.isAnimating <~ vm.isLoading
        privacyPolicy.isHidden = !isRegistering
        termsOfService.isHidden = !isRegistering
        navigationItem.title = .tr("Login." + (isRegistering ? "Register" : "Login"))
        username.isHidden = !isRegistering
        button.setTitle(navigationItem.title, for: .normal)
    }

    @IBAction
    func onEmailDidEndOnExit() {
        if isRegistering {
            username.becomeFirstResponder()
        } else {
            email.resignFirstResponder()
            onLoginPressed()
        }
    }

    @IBAction
    func onUsernameDidEndOnExit() {
        username.resignFirstResponder()
        onLoginPressed()
    }

    @IBAction
    func onLoginPressed() {
        if isRegistering {
            vm.register()
        } else {
            vm.login()
        }
    }

    @IBAction
    func onPrivacyPolicyPressed() {
        URL(string: .tr("Legal.PrivacyPolicy.Url"))?.browse()
    }

    @IBAction
    func onTermsOfServicePressed() {
        URL(string: .tr("Legal.TermsOfService.Url"))?.browse()
    }

    private func askPassword() {
        let alert = UIAlertController(
            title: .tr("Login.Password.Title"),
            message: nil,
            preferredStyle: .alert
        )
        var password = ""
        let ok = UIAlertAction(title: .tr("Ok"), style: .default) { [unowned self] _ in
            vm.login(with: password)
        }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)

        alert.addTextField {
            $0.textContentType = .password
            $0.returnKeyType = .done
            $0.isSecureTextEntry = true
            $0.reactive.continuousTextValues
                .take(during: $0.reactive.lifetime)
                .observeValues {
                    ok.isEnabled = $0.count > 0
                    password = $0
                }
        }
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func onRegister() {
        NotificationCenter.default.post(name: FPUser.userRegistrationEmailNotification, object: self)
        DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
    }

    func onLogin(withPassword: Bool) {
        if !withPassword {
            NotificationCenter.default.post(name: FPUser.userConnectionEmailNotification, object: self)
        }

        DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        case .cancelled:
            return askPassword()

        case .notFound:
            key = "Login.Error.EmailNotFound"

        case .alreadyExists:
            key = "Login.Error.\(status.message == "email_taken" ? "Email" : "Username")AlreadyExists"

        case .permissionDenied:
            key = ["caller_pending", "caller_deleted", "caller_banned", "username_reserved"].contains(status.message)
                ? "Login.Error.\(status.message!.pascalized)"
                : "Error.Permission"

        case .invalidArgument:
            key = ["invalid_credentials", "invalid_email", "invalid_username", "invalid_password"].contains(status.message)
                ? "Login.Error.\(status.message!.pascalized)"
                : "Error.Validation"

        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }
}
