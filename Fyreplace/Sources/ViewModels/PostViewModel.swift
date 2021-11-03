import Foundation
import ReactiveSwift

class PostViewModel: ViewModel {
    @IBOutlet
    weak var delegate: PostViewModelDelegate!

    let post = MutableProperty<FPPost?>(nil)
    let subscribed = MutableProperty<Bool>(false)

    private lazy var postService = FPPostServiceClient(channel: Self.rpc.channel)

    func retrievePost(id: String) {
        let request = FPStringId.with { $0.id = id }
        let response = postService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrievePost(_:))
        response.whenFailure(delegate.onError(_:))
    }
    
    func updateSubscription(subscribed: Bool) {
        let request = FPSubscription.with {
            $0.id = post.value!.id
            $0.subscribed = subscribed
        }
        let response = postService.updateSubscription(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onUpdateSubscription(subscribed: subscribed) }
        response.whenFailure(delegate.onError(_:))
    }
    
    func report() {
        let request = FPStringId.with { $0.id = post.value!.id }
        let response = postService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let request = FPStringId.with { $0.id = post.value!.id }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDelete() }
        response.whenFailure(delegate.onError(_:))
    }

    private func onRetrievePost(_ post: FPPost) {
        self.post.value = post
        subscribed.value = post.isSubscribed
    }
    
    private func onUpdateSubscription(subscribed: Bool) {
        self.subscribed.value = subscribed
    }
}

@objc
protocol PostViewModelDelegate: ViewModelDelegate {
    func onReport()

    func onDelete()
}
