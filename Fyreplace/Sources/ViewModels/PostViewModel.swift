import Foundation
import ReactiveSwift

class PostViewModel: ViewModel {
    @IBOutlet
    weak var delegate: PostViewModelDelegate?

    let post = MutableProperty<FPPost>(FPPost())
    let subscribed = MutableProperty<Bool>(false)
    var lister: ItemRandomAccessListerProtocol { commentLister }

    private lazy var commentLister = ItemRandomAccessLister<FPComment, FPComments, FPCommentServiceNIOClient>(
        delegatingTo: delegate,
        using: self.commentService,
        contextId: post.value.id
    )
    private var acknowledgedPosition = -1

    func retrieve(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = postService.retrieve(request).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func updateSubscription(subscribed: Bool) {
        let request = FPSubscription.with {
            $0.id = post.value.id
            $0.subscribed = subscribed
        }
        let response = postService.updateSubscription(request).response
        response.whenSuccess { _ in self.onUpdateSubscription(subscribed) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func report() {
        let request = FPId.with { $0.id = post.value.id }
        let response = postService.report(request).response
        response.whenSuccess { _ in self.delegate?.postViewModel(self, didReport: self.post.value.id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func delete() {
        let request = FPId.with { $0.id = post.value.id }
        let response = postService.delete(request).response
        response.whenSuccess { _ in self.delegate?.postViewModel(self, didDelete: self.post.value.id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func reportComment(at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        guard let comment = comment(at: position) else { return }
        let request = FPId.with { $0.id = comment.id }
        let response = commentService.report(request).response
        response.whenSuccess { _ in self.delegate?.postViewModel(self, didReportCommentAtPosition: position, inside: self.post.value.id) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
    }

    func deleteComment(at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        guard let comment = comment(at: position) else { return }
        let request = FPId.with { $0.id = comment.id }
        let response = commentService.delete(request).response
        response.whenSuccess { _ in self.delegate?.postViewModel(self, didDeleteCommentAtPosition: position, inside: self.post.value.id) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
    }

    func acknowledgeComment(at position: Int) {
        guard position > acknowledgedPosition,
              let comment = comment(at: position)
        else { return }

        acknowledgedPosition = position
        NotificationCenter.default.post(
            name: FPComment.wasSeenNotification,
            object: self,
            userInfo: [
                "id": comment.id,
                "postId": post.value.id,
                "commentsLeft": lister.totalCount - 1 - position,
            ]
        )
    }

    func comment(at position: Int) -> FPComment? {
        return commentLister.items[position]
    }

    func makeDeletedComment(fromPosition position: Int) -> FPComment? {
        guard var comment = comment(at: position) else { return nil }
        comment.isDeleted = true
        comment.text = ""
        return comment
    }

    private func onRetrieve(_ post: FPPost) {
        self.post.value = post
        subscribed.value = post.isSubscribed
        acknowledgedPosition = Int(post.commentsRead) - 1
        delegate?.postViewModel(self, didRetrieve: post.id)
    }

    private func onUpdateSubscription(_ subscribed: Bool) {
        self.subscribed.value = subscribed
        delegate?.postViewModel(self, didUpdate: post.value.id, subscribed: subscribed)
    }
}

extension PostViewModel: ItemRandomAccessListViewDelegate {
    func itemRandomAccessListView(_ listViewController: ItemRandomAccessListViewController, itemPreviewTypeAtPosition position: Int) -> String {
        return itemRandomAccessListView(listViewController, hasItemAtPosition: position) ? "Comment" : "Loader"
    }

    func itemRandomAccessListView(_ listViewController: ItemRandomAccessListViewController, hasItemAtPosition position: Int) -> Bool {
        return comment(at: position) != nil
    }
}

@objc
protocol PostViewModelDelegate: ViewModelDelegate, ItemRandomAccessListerDelegate {
    func postViewModel(_ viewModel: PostViewModel, didRetrieve id: Data)

    func postViewModel(_ viewModel: PostViewModel, didUpdate id: Data, subscribed: Bool)

    func postViewModel(_ viewModel: PostViewModel, didReport id: Data)

    func postViewModel(_ viewModel: PostViewModel, didDelete id: Data)

    func postViewModel(_ viewModel: PostViewModel, didReportCommentAtPosition position: Int, inside id: Data, onCompletion handler: @escaping () -> Void)

    func postViewModel(_ viewModel: PostViewModel, didDeleteCommentAtPosition position: Int, inside id: Data, onCompletion handler: @escaping () -> Void)
}
