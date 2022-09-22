import Foundation

class ArchiveViewModel: ViewModel {
    @IBOutlet
    weak var delegate: ArchiveViewModelDelegate!

    private lazy var postLister = makeLister(type: 0)

    func post(atIndex index: Int) -> FPPost {
        return postLister.items[index]
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

    func itemPreviewType(atIndex index: Int) -> String {
        if let chapter = post(atIndex: index).chapters.first, chapter.hasImage {
            return "Image"
        } else {
            return "Text"
        }
    }
}

@objc
protocol ArchiveViewModelDelegate: ViewModelDelegate, ItemListerDelegate {}
