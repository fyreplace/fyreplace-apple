import GRPC
import ReactiveSwift
import UIKit

class MainViewController: UITabBarController {
    @IBOutlet
    var vm: MainViewModel!

    private var navigationBackTitles: [UIViewController: String?] = [:]
    private var urlHandled = false

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

        NotificationCenter.default.reactive
            .notifications(forName: FPPost.notFoundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onPostNotFound($0) }

        toggleAuthenticatedTabs(enabled: currentUser != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !urlHandled,
              let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let url = appDelegate.activityUrl
        else { return }

        urlHandled = true
        handle(url: url)
    }

    private func onUrlOpened(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            return presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }

        handle(url: url)
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

    private func onPostNotFound(_ notification: Notification) {
        (selectedViewController as? UINavigationController)?.popViewController(animated: true)
    }

    private func toggleAuthenticatedTabs(enabled: Bool) {
        tabBar.items?.filter { $0.tag == 1 }.forEach { $0.isEnabled = enabled }
    }

    private func handle(url: URL) {
        if let token = url.fragment {
            switch url.path {
            case "/AccountService.ConfirmActivation":
                vm.confirmActivation(with: token)

            case "/AccountService.ConfirmConnection":
                vm.confirmConnection(with: token)

            case "/UserService.ConfirmEmailUpdate":
                vm.confirmEmailUpdate(with: token)

            default:
                presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
            }
        } else if url.path.hasPrefix("/p/") {
            let parts = url.path.dropFirst(3).split(separator: "/")
            presentPost(id: String(parts.first!), at: .init(parts.last ?? ""))
        } else {
            presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }
    }

    private func presentPost(id postIdShortString: String, at commentPosition: Int? = nil) {
        guard let navigationController = selectedViewController as? UINavigationController,
              let postId = Data(base64ShortString: postIdShortString),
              let postController = storyboard?.instantiateViewController(withIdentifier: "Post") as? PostViewController
        else { return }
        postController.post = .with { $0.id = postId }
        postController.commentPosition = commentPosition
        guard let currentController = navigationController.topViewController else { return }
        navigationBackTitles.updateValue(navigationController.navigationItem.backButtonTitle, forKey: currentController)
        currentController.navigationItem.backButtonTitle = " "
        navigationController.delegate = self
        navigationController.pushViewController(postController, animated: true)
    }
}

extension MainViewController: MainViewModelDelegate {
    func onConfirmActivation() {
        presentBasicAlert(text: "Main.AccountActivated")
    }

    func onConfirmEmailUpdate() {
        presentBasicAlert(text: "Main.EmailChanged")
    }

    func errorKey(for code: Int, with message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .unauthenticated:
            return ["timestamp_exceeded", "invalid_token"].contains(message)
                ? "Main.Error.\(message!.pascalized)"
                : "Error.Authentication"

        case .permissionDenied:
            return ["user_not_pending", "invalid_connection_token"].contains(message)
                ? "Main.Error.\(message!.pascalized)"
                : "Error.Permission"

        default:
            return "Error"
        }
    }
}

extension MainViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let backTitle = navigationBackTitles.removeValue(forKey: viewController) else { return }
        viewController.navigationItem.backButtonTitle = backTitle
    }
}
