import Foundation

class ArchiveViewModel: ViewModel {
    @IBOutlet
    weak var delegate: ArchiveViewModelDelegate!

    private lazy var postLister = ItemLister<FPPost, FPPosts, FPPostServiceClient>(
        delegatingTo: delegate,
        using: FPPostServiceClient(channel: Self.rpc.channel)
    )

    func post(atIndex index: Int) -> FPPost {
        return postLister.items[index]
    }
}

extension ArchiveViewModel: ListViewDelegate {
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
