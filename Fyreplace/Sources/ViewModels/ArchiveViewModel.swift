import Foundation

class ArchiveViewModel: ViewModel {
    @IBOutlet
    weak var delegate: ArchiveViewModelDelegate!

    private lazy var postLister = makeLister(type: 0)

    func post(at position: Int) -> FPPost {
        return postLister.items[position]
    }

    func toggleLister(toOwn ownPosts: Bool) {
        postLister = makeLister(type: ownPosts ? 1 : 0)
    }

    private func makeLister(type: Int) -> PostLister {
        return PostLister(delegatingTo: delegate, using: postService, forward: false, type: type)
    }

    private typealias PostLister = ItemLister<FPPost, FPPosts, FPPostServiceNIOClient>
}

extension ArchiveViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { postLister }

    func itemListView(_ listViewController: ItemListViewController, itemPreviewTypeAtPosition position: Int) -> String {
        if let chapter = post(at: position).chapters.first, chapter.hasImage {
            return "Image"
        } else {
            return "Text"
        }
    }
}

@objc
protocol ArchiveViewModelDelegate: ViewModelDelegate, ItemListerDelegate {}
