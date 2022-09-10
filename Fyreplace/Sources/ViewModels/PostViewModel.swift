import Foundation
import ReactiveSwift

class PostViewModel: ViewModel {
    @IBOutlet
    weak var delegate: PostViewModelDelegate!

    let post = MutableProperty<FPPost>(FPPost())
    let subscribed = MutableProperty<Bool>(false)
    var lister: ItemRandomAccessListerProtocol { commentLister }

    private lazy var postService = FPPostServiceNIOClient(channel: Self.rpc.channel)
    private lazy var commentService = FPCommentServiceNIOClient(channel: Self.rpc.channel)
    private lazy var commentLister = ItemRandomAccessLister<FPComment, FPComments, FPCommentServiceNIOClient>(
        delegatingTo: delegate,
        using: self.commentService,
        contextId: post.value.id
    )

    func retrieve(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = postService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure { self.delegate.onError($0) }
    }

    func updateSubscription(subscribed: Bool) {
        let request = FPSubscription.with {
            $0.id = post.value.id
            $0.subscribed = subscribed
        }
        let response = postService.updateSubscription(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onUpdateSubscription(subscribed) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func report() {
        let request = FPId.with { $0.id = post.value.id }
        let response = postService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure { self.delegate.onError($0) }
    }

    func delete() {
        let request = FPId.with { $0.id = post.value.id }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDelete() }
        response.whenFailure { self.delegate.onError($0) }
    }

    func reportComment(at position: Int) {
        guard let comment = comment(atIndex: position) else { return }
        let request = FPId.with { $0.id = comment.id }
        let response = commentService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReportComment(position) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func deleteComment(at position: Int) {
        guard let comment = comment(atIndex: position) else { return }
        let request = FPId.with { $0.id = comment.id }
        let response = commentService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDeleteComment(position) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func comment(atIndex index: Int) -> FPComment? {
        return commentLister.items[index]
    }

    func makeDeletedComment(fromPosition position: Int) -> FPComment? {
        guard var comment = comment(atIndex: position) else { return nil }
        comment.isDeleted = true
        comment.text = ""
        return comment
    }

    private func onRetrieve(_ post: FPPost) {
        self.post.value = post
        subscribed.value = post.isSubscribed
        delegate.onRetrieve()
    }

    private func onUpdateSubscription(_ subscribed: Bool) {
        self.subscribed.value = subscribed
        delegate.onUpdateSubscription(subscribed)
    }
}

extension PostViewModel: ItemRandomAccessListViewDelegate {
    func itemPreviewType(atIndex index: Int) -> String {
        return hasItem(atIndex: index) ? "Comment" : "Loader"
    }

    func hasItem(atIndex index: Int) -> Bool {
        return comment(atIndex: index) != nil
    }
}

@objc
protocol PostViewModelDelegate: ViewModelDelegate, ItemRandomAccessListerDelegate {
    func onRetrieve()

    func onUpdateSubscription(_ subscribed: Bool)

    func onReport()

    func onDelete()

    func onReportComment(_ position: Int)

    func onDeleteComment(_ position: Int)
}
