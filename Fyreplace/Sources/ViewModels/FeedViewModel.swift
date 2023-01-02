import Foundation
import GRPC
import ReactiveSwift

class FeedViewModel: ViewModel {
    @IBOutlet
    weak var delegate: FeedViewModelDelegate?

    private var stream: BidirectionalStreamingCall<FPVote, FPPost>?
    private var posts: [FPPost] = []

    func post(at position: Int) -> FPPost? {
        return posts[position, default: nil]
    }

    func startListing() {
        stream = postService.listFeed(callOptions: .authenticated) { [self] post in
            if let index = posts.firstIndex(where: { $0.id == post.id }) {
                posts[index] = post
                delegate?.feedViewModel(self, didUpdatePostAtPosition: index)
            } else {
                posts += [post]
                delegate?.feedViewModel(self, didReceivePostAtPosition: posts.count - 1)
            }
        }
        stream!.status.whenComplete { [self] _ in delegate?.didFinishListing(self) }
    }

    func stopListing() {
        _ = stream?.sendEnd()
    }

    func refresh() {
        stopListing()
        posts = []
        startListing()
    }

    func vote(spread: Bool, at position: Int) {
        let postId = posts[position].id
        let response = stream?.sendMessage(.with {
            $0.postID = postId
            $0.spread = spread
        })
        response?.whenSuccess { [self] in
            posts.removeAll { $0.id == postId }
            delegate?.feedViewModel(self, didVotePostAtPosition: position)
        }
    }
}

@objc
protocol FeedViewModelDelegate: ViewModelDelegate {
    func feedViewModel(_ viewModel: FeedViewModel, didReceivePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didUpdatePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didVotePostAtPosition position: Int)

    func didFinishListing(_ viewModel: FeedViewModel)
}
