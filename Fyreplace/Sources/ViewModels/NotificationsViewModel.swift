import Foundation
import ReactiveSwift

class NotificationsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: NotificationsViewModelDelegate?

    private lazy var notificationLister = ItemLister<FPNotification, FPNotifications, FPNotificationServiceNIOClient>(
        delegatingTo: delegate,
        using: notificationService,
        forward: false
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPComment.wasSeenNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentWasSeen($0) }

        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didReceiveRemoteNotificationNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onAppDidReceiveRemoteNotification($0) }
    }

    func notification(at position: Int) -> FPNotification {
        return notificationLister.items[position]
    }

    func absolve(at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let notification = notification(at: position)

        switch notification.target {
        case let .user(user):
            absolveUser(id: user.id, at: position, onCompletion: completion)

        case let .post(post):
            absolveUser(id: post.id, at: position, onCompletion: completion)

        case let .comment(comment):
            absolveUser(id: comment.id, at: position, onCompletion: completion)

        default:
            return
        }
    }

    private func absolveUser(id: Data, at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let request = FPId.with { $0.id = id }
        let response = userService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.notificationsViewModel(self, didAbsolve: id, at: position) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
    }

    private func absolvePost(id: Data, at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let request = FPId.with { $0.id = id }
        let response = postService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.notificationsViewModel(self, didAbsolve: id, at: position) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
    }

    private func absolveComment(id: Data, at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let request = FPId.with { $0.id = id }
        let response = commentService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.notificationsViewModel(self, didAbsolve: id, at: position) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
    }

    private func onCommentWasSeen(_ notification: Notification) {
        guard let info = notification.userInfo,
              let postId = info["postId"] as? Data,
              let commentsLeft = info["commentsLeft"] as? Int
        else { return }
        var postNotification = FPNotification.with { $0.post = .with { $0.id = postId } }
        let position = lister.getPosition(for: postNotification)
        guard position != -1 else { return }
        postNotification = self.notification(at: position)
        guard commentsLeft < postNotification.count,
              postId == postNotification.post.id
        else { return }

        let notificationName: Notification.Name

        if commentsLeft == 0 {
            notificationName = FPNotification.wasDeletedNotification
        } else {
            postNotification.count = UInt32(commentsLeft)
            notificationName = FPNotification.wasUpdatedNotification
        }

        NotificationCenter.default.post(
            name: notificationName,
            object: self,
            userInfo: ["item": postNotification]
        )
    }

    private func onAppDidReceiveRemoteNotification(_ notification: Notification) {
        guard let info = notification.userInfo,
              let command = info["_command"] as? String,
              let postIdString = info["postId"] as? String,
              let postId = Data(base64ShortString: postIdString)
        else { return }

        let position = lister.getPosition(for: FPNotification.with { $0.post = .with { $0.id = postId } })

        if position == -1 {
            return NotificationCenter.default.post(
                name: FPNotification.wasCreatedNotification,
                object: self
            )
        }

        var postNotification = self.notification(at: position)

        if postNotification.count == 1, command == "comment:deletion" {
            return NotificationCenter.default.post(
                name: FPNotification.wasDeletedNotification,
                object: self,
                userInfo: ["item": postNotification]
            )
        }

        if command == "comment:creation" {
            postNotification.count += 1
        } else if command == "comment:deletion" {
            postNotification.count -= 1
        }

        NotificationCenter.default.post(
            name: FPNotification.wasUpdatedNotification,
            object: self,
            userInfo: ["item": postNotification]
        )
    }
}

extension NotificationsViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { notificationLister }

    func itemListView(_ listViewController: ItemListViewController, itemPreviewTypeAtPosition position: Int) -> String {
        let notification = notification(at: position)

        switch notification.target! {
        case .user:
            return "User"

        case .post:
            return notification.post.chapters.first?.hasImage == true ? "Image Post" : "Text Post"

        case .comment:
            return "Comment"
        }
    }
}

@objc
protocol NotificationsViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func notificationsViewModel(_ viewModel: NotificationsViewModel, didAbsolve id: Data, at position: Int, onCompletion handler: @escaping () -> Void)
}
