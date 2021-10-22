import UIKit
import ReactiveSwift
import ReactiveCocoa
import GRPC

class LoginViewController: UIViewController {
    @IBOutlet
    var vm: LoginViewModel!
    @IBOutlet
    var email: UITextField!
    @IBOutlet
    var username: UITextField!
    @IBOutlet
    var password: UITextField!
    @IBOutlet
    var button: UIButton!
    @IBOutlet
    var loader: UIActivityIndicatorView!

    public var isRegistering = true

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.isRegistering.value = isRegistering
        vm.email <~ email.reactive.continuousTextValues
        vm.username <~ username.reactive.continuousTextValues
        vm.password <~ password.reactive.continuousTextValues
        button.reactive.isEnabled <~ vm.canProceed
        button.reactive.isHidden <~ vm.isLoading
        loader.reactive.isAnimating <~ vm.isLoading
        navigationItem.title = .tr("Login." + (isRegistering ? "Register" : "Login"))
        email.isHidden = !isRegistering
        button.setTitle(navigationItem.title, for: .normal)
    }

    @IBAction
    private func onEmailDidEndOnExit() {
        username.becomeFirstResponder()
    }

    @IBAction
    private func onUsernameDidEndOnExit() {
        password.becomeFirstResponder()
    }

    @IBAction
    private func onPasswordDidEndOnExit() {
        onLoginPressed()
    }

    @IBAction
    private func onLoginPressed() {
        password.resignFirstResponder()

        if isRegistering {
            vm.register()
        } else {
            vm.login()
        }
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func onRegister() {
        NotificationCenter.default.post(name: FPUser.userRegisteredNotification, object: self)
        DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
    }

    func onLogin() {
        DispatchQueue.main.async { self.navigationController?.popViewController(animated: true) }
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        case .alreadyExists:
            key = "Login.Error.Existing\(status.message == "email_taken" ? "Email" : "Username")"

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
