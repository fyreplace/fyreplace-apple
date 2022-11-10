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
        accountService = FPAccountServiceNIOClient(channel: Self.rpc.channel)
        userService = FPUserServiceNIOClient(channel: Self.rpc.channel)
        postService = FPPostServiceNIOClient(channel: Self.rpc.channel)
        chapterService = FPChapterServiceNIOClient(channel: Self.rpc.channel)
        commentService = FPCommentServiceNIOClient(channel: Self.rpc.channel)
        notificationService = FPNotificationServiceNIOClient(channel: Self.rpc.channel)
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

        switch status.code {
        case .unavailable:
            key = "Error.Unavailable"

        case .unauthenticated:
            if autoDisconnect, Keychain.authToken.get() != nil {
                key = nil

                if Keychain.authToken.delete() {
                    setCurrentUser(nil)
                }
            } else {
                key = self.viewModel(viewModel, errorKeyForCode: status.code.rawValue, withMessage: status.message)
            }

        default:
            key = self.viewModel(viewModel, errorKeyForCode: status.code.rawValue, withMessage: status.message)
        }

        if let key = key {
            presentBasicAlert(text: key, feedback: .error)
        }
    }
}
