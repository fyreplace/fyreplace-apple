import Foundation
import GRPC

class FeedViewModel: ViewModel {
    @IBOutlet
    weak var delegate: FeedViewModelDelegate?

    private var stream: BidirectionalStreamingCall<FPVote, FPPost>?
    private var posts: [FPPost] = []
    private var stalePostIds = Set<Data>()

    func post(at position: Int) -> FPPost? {
        return posts[position, default: nil]
    }

    func startListing() {
        stalePostIds = .init(posts.map(\.id))
        stream = postService.listFeed { [self] post in
            if let position = posts.firstIndex(where: { $0.id == post.id }) {
                if post != posts[position] {
                    posts[position] = post
                    delegate?.feedViewModel(self, didUpdatePostAtPosition: position)
                }

                stalePostIds.remove(post.id)
                pruneStalePosts(before: position)
            } else {
                posts.append(post)
                delegate?.feedViewModel(self, didReceivePostAtPosition: posts.count - 1)
                pruneStalePosts(before: posts.count)
            }
        }
        stream!.status.whenComplete { [self] _ in
            pruneStalePosts(before: posts.count)
            delegate?.didFinishListing(self)
        }
    }

    func stopListing() {
        _ = stream?.sendEnd()
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

    private func pruneStalePosts(before index: Int) {
        for i in (0 ..< index).reversed() where stalePostIds.contains(posts[i].id) {
            stalePostIds.remove(posts.remove(at: i).id)
            delegate?.feedViewModel(self, didDismissPostAtPosition: i)
        }
    }
}

@objc
protocol FeedViewModelDelegate: ViewModelDelegate {
    func feedViewModel(_ viewModel: FeedViewModel, didReceivePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didUpdatePostAtPosition position: Int)

    func feedViewModel(_ viewModel: FeedViewModel, didDismissPostAtPosition position: Int)

    func didFinishListing(_ viewModel: FeedViewModel)
}
