import GRPC
import Kingfisher
import ReactiveSwift
import UIKit
import UserNotifications

class MainViewController: UITabBarController {
    @IBOutlet
    var vm: MainViewModel!

    private var navigationBackTitles: [UIViewController: String?] = [:]
    private var lastHandledUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didOpenUrlNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onAppDidOpenUrl($0) }

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didUpdateRemoteNotificationTokenNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onAppDidUpdateRemoteNotificationToken($0) }

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didReceiveRemoteNotificationNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onAppDidReceiveRemoteNotification($0) }

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didOpenRemoteNotificationNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onAppDidOpenRemoteNotification($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidSendRegistrationEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCurrentUserDidSendRegistrationEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidSendConnectionEmailNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCurrentUserDidSendConnectionEmail($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidChangeNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCurrentUserDidChange($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPPost.wasNotFoundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onPostWasNotFound($0) }

        NotificationCenter.default.reactive
            .notifications(forName: FPComment.wasSeenNotification)
            .debounce(1, on: QueueScheduler.main)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentWasSeen($0) }

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

    private func onAppDidOpenUrl(_ notification: Notification) {
        guard let url = notification.userInfo?["url"] as? URL else {
            return presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }

        handle(url: url)
    }

    private func onAppDidUpdateRemoteNotificationToken(_ notification: Notification) {
        guard let info = notification.userInfo,
              let token = info["token"] as? String
        else { return }
        vm.registerToken(token: token)
    }

    private func onAppDidReceiveRemoteNotification(_ notification: Notification) {
        guard UIApplication.shared.applicationState != .background,
              let info = notification.userInfo,
              info["_command"] as? String == "comment:creation",
              let serializedComment = info["comment"],
              let comment = try? FPComment(jsonUTF8Data: .init(jsonObject: serializedComment)),
              let postIdString = info["postId"] as? String,
              let postId = Data(base64ShortString: postIdString)
        else { return }

        let postController = findPostViewController()

        if postController?.tryHandleCommentCreation(for: postId) == true {
            return
        }

        let content = makeUserNotificationContent(comment: comment, postId: postId, info: info)

        if postId == postController?.vm.post.value.id {
            content.subtitle = .tr("Notification.Comment.Creation.Subtitle")
            content.userInfo["_aps.list"] = false
        }

        createUserNotification(withIdentifier: comment.id.base64ShortString, withContent: content)
    }

    private func onAppDidOpenRemoteNotification(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        let completionHandler = info["_completionHandler"] as? () -> Void
        defer { completionHandler?() }

        guard let postIdString = info["postId"] as? String,
              let postId = Data(base64ShortString: postIdString)
        else { return }

        presentPost(id: postId)
    }

    private func onCurrentUserDidSendRegistrationEmail(_ notification: Notification) {
        presentBasicAlert(text: "Main.AccountCreated")
    }

    private func onCurrentUserDidSendConnectionEmail(_ notification: Notification) {
        presentBasicAlert(text: "Main.Connection")
    }

    private func onCurrentUserDidChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let connected = info["connected"] as? Bool
        else { return }
        toggleAuthenticatedTabs(enabled: connected)

        if connected {
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
            UIApplication.shared.applicationIconBadgeNumber = 0
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()

            if tabBar.selectedItem?.tag == 1 {
                selectedIndex = (tabBar.items?.count ?? 1) - 1
            }
        }
    }

    private func onPostWasNotFound(_ notification: Notification) {
        (selectedViewController as? UINavigationController)?.popViewController(animated: true)
    }

    private func onCommentWasSeen(_ notification: Notification) {
        guard let info = notification.userInfo,
              let commentId = info["id"] as? Data
        else { return }
        vm.acknowledgeComment(id: commentId)
    }

    private func toggleAuthenticatedTabs(enabled: Bool) {
        tabBar.items?.filter { $0.tag == 1 }.forEach { $0.isEnabled = enabled }
    }

    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
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
            presentPost(id: postId, at: commentPosition)
        } else {
            presentBasicAlert(text: "Main.Error.MalformedUrl", feedback: .error)
        }
    }

    private func presentPost(id postId: Data, at commentPosition: Int? = nil) {
        guard currentUser != nil else {
            return presentBasicAlert(text: "Error.Authentication")
        }

        if let postController = findPostViewController() {
            if let commentPosition = commentPosition,
               postController.tryShowComment(for: postId, at: commentPosition)
            {
                return
            }

            if postController.vm.post.value.id == postId {
                return postController.showUnreadComments()
            }
        }

        guard let navigationController = selectedViewController as? UINavigationController,
              let currentController = navigationController.topViewController,
              let postController = storyboard?.instantiateViewController(withIdentifier: "Post") as? PostViewController
        else { return presentBasicAlert(text: "Error") }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            postController.post = .with { $0.id = postId }
            postController.selectedComment = commentPosition
            self.navigationBackTitles[currentController] = currentController.navigationItem.backButtonTitle
            currentController.navigationItem.backButtonTitle = " "
            navigationController.delegate = self
            navigationController.pushViewController(postController, animated: true)
        }
    }

    private func findPostViewController() -> PostViewController? {
        if let navigationController = selectedViewController as? UINavigationController,
           let postController = navigationController.topViewController as? PostViewController
        {
            return postController
        } else {
            return nil
        }
    }
}

extension MainViewController: MainViewModelDelegate {
    func mainViewModel(_ viewModel: MainViewModel, didConfirmActivationWithToken token: String) {
        NotificationCenter.default.post(name: FPUser.currentDidConnectNotification, object: self)
        presentBasicAlert(text: "Main.AccountActivated", then: requestNotificationAuthorization)
    }

    func mainViewModel(_ viewModel: MainViewModel, didConfirmConnectionWithToken token: String) {
        NotificationCenter.default.post(name: FPUser.currentDidConnectNotification, object: self)
        requestNotificationAuthorization()
    }

    func mainViewModel(_ viewModel: MainViewModel, didConfirmEmailUpdateWithToken token: String) {
        presentBasicAlert(text: "Main.EmailChanged")
    }

    func mainViewModel(_ viewModel: MainViewModel, didAcknowledgeComment id: Data) {}

    func mainViewModel(_ viewModel: MainViewModel, didRegisterToken token: String) {}

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
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
