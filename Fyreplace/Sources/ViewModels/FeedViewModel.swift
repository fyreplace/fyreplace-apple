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
        let response = stream?.sendMessage(.with {
            $0.postID = posts[position].id
            $0.spread = spread
        })
        response?.whenSuccess { [self] in
            posts.remove(at: position)
            delegate?.feedViewModel(self, didVotePostAtPosition: position)
        }
    }
}

@objc
protocol FeedViewModelDelegate: ViewModelDelegate {
    func feedViewModel(_ viewModel: FeedViewModel, didReceivePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didVotePostAtPosition position: Int)

    func didFinishListing(_ viewModel: FeedViewModel)
}
