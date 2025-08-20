import GRPC
import ReactiveSwift
import UIKit

class ViewModel: NSObject {
    static let rpc = Rpc()
    var accountService: FPAccountServiceNIOClient!
    var userService: FPUserServiceNIOClient!
    var postService: FPPostServiceNIOClient!
    var chapterService: FPChapterServiceNIOClient!
    var commentService: FPCommentServiceNIOClient!
    var notificationService: FPNotificationServiceNIOClient!

    override init() {
        super.init()
        setupServices()
        NotificationCenter.default.reactive
            .notifications(forName: Rpc.didChangeChannelNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onRpcDidChangeChannel($0) }
    }

    private func onRpcDidChangeChannel(_ notification: Notification) {
        setupServices()
    }

    private func setupServices() {
        accountService = FPAccountServiceNIOClient(channel: Self.rpc.channel, interceptors: AccountServiceClientInterceptorFactory())
        userService = FPUserServiceNIOClient(channel: Self.rpc.channel, interceptors: UserServiceClientInterceptorFactory())
        postService = FPPostServiceNIOClient(channel: Self.rpc.channel, interceptors: PostServiceClientInterceptorFactory())
        chapterService = FPChapterServiceNIOClient(channel: Self.rpc.channel, interceptors: ChapterServiceClientInterceptorFactory())
        commentService = FPCommentServiceNIOClient(channel: Self.rpc.channel, interceptors: CommentServiceClientInterceptorFactory())
        notificationService = FPNotificationServiceNIOClient(channel: Self.rpc.channel, interceptors: NotificationServiceClientInterceptorFactory())
    }
}

@objc
protocol ViewModelDelegate where Self: UIViewController {
    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String?
}

extension ViewModelDelegate {
    func viewModel(_ viewModel: ViewModel, didFailWithError error: Error, canAutoDisconnect autoDisconnect: Bool = true) {
        DispatchQueue.main.async {
            self.onFailure(viewModel: viewModel, error: error, canAutoDisconnect: autoDisconnect)
        }
    }

    private func onFailure(viewModel: ViewModel, error: Error, canAutoDisconnect autoDisconnect: Bool) {
        let key: String?
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        switch (status.code, autoDisconnect) {
        case (.unavailable, _):
            key = "Error.Unavailable"

        case (.unauthenticated, true):
            if KeychainWrapper.authToken.get() != nil {
                presentBasicAlert(text: "Error.Autodisconnect", feedback: .error)
            }

            key = nil

            if UIApplication.shared.applicationState == .active {
                _ = KeychainWrapper.authToken.delete()
                setCurrentUser(nil)
            }

        default:
            key = self.viewModel(viewModel, errorKeyForCode: status.code.rawValue, withMessage: status.message)
        }

        if let key {
            presentBasicAlert(text: key, feedback: .error)
        }
    }
}
