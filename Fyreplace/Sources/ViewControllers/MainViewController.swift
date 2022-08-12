import GRPC
import ReactiveSwift
import UIKit

class MainViewController: UITabBarController {
    @IBOutlet
    var vm: MainViewModel!

    private var navigationBackTitles: [UIViewController: String?] = [:]
    private var lastHandledUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.urlOpenedNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onUrlOpened($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.registrationEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserRegistrationEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.connectionEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserConnectionEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.connectionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserConnection($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.disconnectionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onUserDisconnection($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPPost.notFoundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onPostNotFound($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPComment.seenNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentSeen($0) }

        toggleAuthenticatedTabs(enabled: currentUser != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let url = appDelegate.activityUrl,
              url != lastHandledUrl
        else { return }

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

    private func onUserConnection(_ notification: Notification) {
        toggleAuthenticatedTabs(enabled: true)
    }

    private func onUserDisconnection(_ notification: Notification) {
        toggleAuthenticatedTabs(enabled: false)

        if tabBar.selectedItem?.tag == 1 {
            selectedIndex = (tabBar.items?.count ?? 1) - 1
        }
    }

    private func onPostNotFound(_ notification: Notification) {
        (selectedViewController as? UINavigationController)?.popViewController(animated: true)
    }

    private func onCommentSeen(_ notification: Notification) {
        guard let info = notification.userInfo,
              let commentId = info["id"] as? Data
        else { return }
        vm.acknowledgeComment(id: commentId)
    }

    private func toggleAuthenticatedTabs(enabled: Bool) {
        tabBar.items?.filter { $0.tag == 1 }.forEach { $0.isEnabled = enabled }
    }

    private func handle(url: URL) {
        lastHandledUrl = url

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
            let commentPosition = Int(parts.last ?? "")
            guard let postIdString = parts.first,
                  let postId = Data(base64ShortString: .init(postIdString))
            else { return presentBasicAlert(text: "Main.Error.MalformedUrl") }

            if let commentPosition = commentPosition,
               let navigationController = selectedViewController as? UINavigationController,
               let postController = navigationController.topViewController as? PostViewController,
               postController.tryShowComment(for: postId, at: commentPosition)
            {
                return
            } else {
                presentPost(id: postId, at: commentPosition)
            }
        } else {
            presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }
    }

    private func presentPost(id postId: Data, at commentPosition: Int? = nil) {
        guard currentUser != nil else {
            return presentBasicAlert(text: "Error.Authentication")
        }

        guard let navigationController = selectedViewController as? UINavigationController,
              let currentController = navigationController.topViewController,
              let postController = storyboard?.instantiateViewController(withIdentifier: "Post") as? PostViewController
        else { return presentBasicAlert(text: "Error") }

        postController.post = .with { $0.id = postId }
        postController.commentPosition = commentPosition
        navigationBackTitles.updateValue(navigationController.navigationItem.backButtonTitle, forKey: currentController)
        currentController.navigationItem.backButtonTitle = " "
        navigationController.delegate = self
        navigationController.pushViewController(postController, animated: true)
    }
}

extension MainViewController: MainViewModelDelegate {
    func onConfirmActivation() {
        onConfirmConnection()
        presentBasicAlert(text: "Main.AccountActivated")
    }

    func onConfirmConnection() {
        NotificationCenter.default.post(name: FPUser.connectionNotification, object: self)
    }

    func onConfirmEmailUpdate() {
        presentBasicAlert(text: "Main.EmailChanged")
    }

    func onAcknowledgeComment() {}

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
