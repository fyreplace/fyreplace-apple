import Foundation
import ReactiveSwift

class NotificationsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: NotificationsViewModelDelegate!

    private lazy var notificationLister = ItemLister<FPNotification, FPNotifications, FPNotificationServiceNIOClient>(
        delegatingTo: delegate,
        using: notificationService,
        forward: false
    )

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPComment.seenNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentSeen($0) }
    }

    func notification(atIndex index: Int) -> FPNotification {
        return notificationLister.items[index]
    }

    func absolve(notification: FPNotification) {
        switch notification.target {
        case let .user(user):
            absolveUser(id: user.id)

        case let .post(post):
            absolveUser(id: post.id)

        case let .comment(comment):
            absolveUser(id: comment.id)

        default:
            return
        }
    }

    private func absolveUser(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = userService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onAbsolveUser() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func absolvePost(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = postService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onAbsolvePost() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func absolveComment(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = commentService.absolve(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onAbsolveComment() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onCommentSeen(_ notification: Notification) {
        guard let info = notification.userInfo,
              let postId = info["postId"] as? Data,
              let commentsLeft = info["commentsLeft"] as? Int
        else { return }
        var postNotification = FPNotification.with { $0.post = .with { $0.id = postId } }
        let position = lister.getPosition(for: postNotification)
        guard position != -1 else { return }
        postNotification = self.notification(atIndex: position)
        guard commentsLeft < postNotification.count,
              postId == postNotification.post.id
        else { return }

        let notificationName: Notification.Name

        if commentsLeft == 0 {
            notificationName = FPNotification.deletionNotification
        } else {
            postNotification.count = UInt32(commentsLeft)
            notificationName = FPNotification.updateNotification
        }

        NotificationCenter.default.post(
            name: notificationName,
            object: self,
            userInfo: ["item": postNotification]
        )
    }
}

extension NotificationsViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { notificationLister }

    func itemPreviewType(atIndex index: Int) -> String {
        let notification = notification(atIndex: index)

        switch notification.target! {
        case .user:
            return "User"

        case .post:
            return notification.post.chapters.first?.hasImage ?? false ? "Image Post" : "Text Post"

        case .comment:
            return "Comment"
        }
    }
}

@objc
protocol NotificationsViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func onAbsolveUser()

    func onAbsolvePost()

    func onAbsolveComment()
}
