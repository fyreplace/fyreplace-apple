import UIKit
import ReactiveSwift
import ReactiveCocoa
import GRPC

class LoginViewController: UIViewController {
    @IBOutlet
    private var vm: LoginViewModel!
    @IBOutlet
    private var email: UITextField!
    @IBOutlet
    private var username: UITextField!
    @IBOutlet
    private var password: UITextField!
    @IBOutlet
    private var button: UIButton!
    @IBOutlet
    private var loader: UIActivityIndicatorView!

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
        DispatchQueue.main.async { [self] in
            navigationController?.popViewController(animated: true)
            presentBasicAlert(text: "Login.Register")
        }
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
            key = ["caller_pending", "caller_deleted", "caller_banned"].contains(status.message)
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
