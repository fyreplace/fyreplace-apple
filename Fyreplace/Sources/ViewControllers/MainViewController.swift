import UIKit
import ReactiveSwift
import GRPC

class MainViewController: UITabBarController {
    @IBOutlet
    var vm: MainViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.urlOpenedNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onUrlOpened($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userRegistrationEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserRegistrationEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userConnectionEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserConnectionEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userConnectedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserConnected($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userDisconnectedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserDisconnected($0) }

        toggleAuthenticatedTabs(enabled: getCurrentUser() != nil)
    }

    private func onUrlOpened(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL,
              let fragment = url.fragment
        else { return presentBasicAlert(text: "Error", feedback: .error) }

        switch url.path {
        case "/AccountService.ConfirmActivation":
            vm.confirmActivation(with: fragment)

        case "/AccountService.ConfirmConnection":
            vm.confirmConnection(with: fragment)

        case "/UserService.ConfirmEmailUpdate":
            vm.confirmEmailUpdate(with: fragment)

        default:
            presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }
    }

    private func onUserRegistrationEmail(_ notification: Notification) {
        presentBasicAlert(text: "Main.AccountCreated")
    }

    private func onUserConnectionEmail(_ notification: Notification) {
        presentBasicAlert(text: "Main.Connection")
    }

    private func onUserConnected(_ notification: Notification) {
        toggleAuthenticatedTabs(enabled: true)
    }

    private func onUserDisconnected(_ notification: Notification) {
        toggleAuthenticatedTabs(enabled: false)

        if tabBar.selectedItem?.tag == 1 {
            selectedIndex = (tabBar.items?.count ?? 1) - 1
        }
    }

    private func toggleAuthenticatedTabs(enabled: Bool) {
        tabBar.items?.filter { $0.tag == 1 }.forEach { $0.isEnabled = enabled }
    }
}

extension MainViewController: MainViewModelDelegate {
    func onConfirmActivation() {
        presentBasicAlert(text: "Main.AccountActivated")
    }

    func onConfirmEmailUpdate() {
        presentBasicAlert(text: "Main.EmailChanged")
    }

    func onFailure(_ error: Error) {
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
}
