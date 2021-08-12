import UIKit
import GRPC

class MainViewController: UITabBarController, MainViewModelDelegate {
    @IBOutlet
    private var vm: MainViewModel!

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onUrlOpened(_:)), name: AppDelegate.urlOpenedNotification, object: nil)
    }

    func onConfirmActivation() {
        presentBasicAlert(text: "Main.AccountActivated")
    }

    func onFailure(_ error: Error) {
        if let error = error as? KeychainError {
            presentBasicAlert(text: error.alertText, feedback: .error)
        }

        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        case .unauthenticated:
            key = ["timestamp_exceeded", "invalid_token"].contains(status.message)
                ? "Main.Error.\(status.message!.pascalized)"
                : "Error.Authentication"

        case .permissionDenied:
            key = status.message == "user_not_pending" ? "Main.Error.UserNotPending" : "Error.Permission"

        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }

    @objc
    private func onUrlOpened(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }
        guard url.scheme == "fyreplace", url.host?.isEmpty ?? true else {
            return presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }

        switch url.path {
        case "/AccountService.ConfirmActivation":
            vm.confirmActivation(with: url.fragment ?? "")

        default:
            presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }
    }
}
