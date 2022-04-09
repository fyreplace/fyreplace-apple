import Foundation

class DraftsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftsViewModelDelegate!

    private lazy var draftLister = ItemLister<FPPost, FPPosts, FPPostServiceClient>(
        delegatingTo: delegate,
        using: FPPostServiceClient(channel: Self.rpc.channel),
        forward: false,
        type: 1
    )

    func post(atIndex index: Int) -> FPPost {
        return draftLister.items[index]
    }
}

extension DraftsViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { draftLister }

    func itemPreviewType(atIndex index: Int) -> String {
        guard let chapter = post(atIndex: index).chapters.first else { return "Empty" }
        return chapter.hasImage ? "Image" : "Text"
    }
}

@objc
protocol DraftsViewModelDelegate: ViewModelDelegate, ItemListerDelegate {}
