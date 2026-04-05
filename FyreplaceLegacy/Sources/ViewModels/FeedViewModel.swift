import Foundation
import GRPC

class FeedViewModel: ViewModel {
    @IBOutlet
    weak var delegate: FeedViewModelDelegate?

    private var stream: BidirectionalStreamingCall<FPVote, FPPost>?
    private var posts: [FPPost] = []

    func post(at position: Int) -> FPPost? {
        return posts[position, default: nil]
    }

    func startListing() {
        stream = postService.listFeed { [self] post in
            if let position = posts.firstIndex(where: { $0.id == post.id }) {
                if post != posts[position] {
                    posts[position] = post
                    delegate?.feedViewModel(self, didUpdatePostAtPosition: position)
                }
            } else {
                posts += [post]
                delegate?.feedViewModel(self, didReceivePostAtPosition: posts.count - 1)
            }
        }
        stream!.status.whenComplete { [self] _ in delegate?.didFinishListing(self) }
    }

    func stopListing() {
        _ = stream?.sendEnd()
        posts = []
        delegate?.didRemoveAllPosts(self)
    }

    func refresh() {
        stopListing()
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
            delegate?.feedViewModel(self, didDismissPostAtPosition: position)
        }
    }
}

@objc
protocol FeedViewModelDelegate: ViewModelDelegate {
    func feedViewModel(_ viewModel: FeedViewModel, didReceivePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didUpdatePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didDismissPostAtPosition position: Int)

    func didRemoveAllPosts(_ viewModel: FeedViewModel)

    func didFinishListing(_ viewModel: FeedViewModel)
}
