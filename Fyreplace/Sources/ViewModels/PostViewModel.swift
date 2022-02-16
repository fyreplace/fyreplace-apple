import Foundation
import ReactiveSwift

class PostViewModel: ViewModel {
    @IBOutlet
    weak var delegate: PostViewModelDelegate!

    let post = MutableProperty<FPPost?>(nil)
    let subscribed = MutableProperty<Bool>(false)
    var lister: ItemRandomAccessListerProtocol { commentLister }
    var commentCount: Int { commentLister.totalCount }

    private var postId: Data!
    private lazy var postService = FPPostServiceClient(channel: Self.rpc.channel)
    private lazy var commentLister = ItemRandomAccessLister<FPComment, FPComments, FPCommentServiceClient>(
        delegatingTo: delegate,
        using: FPCommentServiceClient(channel: Self.rpc.channel),
        contextId: postId
    )

    func retrieve(id: Data) {
        postId = id
        let request = FPId.with { $0.id = id }
        let response = postService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure(delegate.onError(_:))
    }

    func updateSubscription(subscribed: Bool) {
        let request = FPSubscription.with {
            $0.id = postId
            $0.subscribed = subscribed
        }
        let response = postService.updateSubscription(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onUpdateSubscription(subscribed) }
        response.whenFailure(delegate.onError(_:))
    }

    func report() {
        let request = FPId.with { $0.id = postId }
        let response = postService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDelete() }
        response.whenFailure(delegate.onError(_:))
    }

    func comment(atIndex index: Int) -> FPComment? {
        return commentLister.items[index]
    }

    private func onRetrieve(_ post: FPPost) {
        self.post.value = post
        subscribed.value = post.isSubscribed
    }

    private func onUpdateSubscription(_ subscribed: Bool) {
        self.subscribed.value = subscribed
        delegate.onUpdateSubscription(subscribed)
    }
}

@objc
protocol PostViewModelDelegate: ViewModelDelegate, ItemRandomAccessListerDelegate {
    func onUpdateSubscription(_ subscribed: Bool)

    func onReport()

    func onDelete()
}
