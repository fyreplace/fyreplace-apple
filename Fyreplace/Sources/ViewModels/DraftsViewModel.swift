import Foundation
import ReactiveSwift
import SwiftProtobuf

class DraftsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftsViewModelDelegate!

    let isLoading = MutableProperty(false)

    private lazy var postService = FPPostServiceNIOClient(channel: Self.rpc.channel)
    private lazy var draftLister = ItemLister<FPPost, FPPosts, FPPostServiceNIOClient>(
        delegatingTo: delegate,
        using: postService,
        forward: false,
        type: 2
    )

    func post(atIndex index: Int) -> FPPost {
        return draftLister.items[index]
    }

    func create() {
        isLoading.value = true
        let request = Google_Protobuf_Empty()
        let response = postService.create(request, callOptions: .authenticated).response
        response.whenSuccess { self.onCreate($0) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func delete(_ postId: Data) {
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDelete() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onCreate(_ postId: FPId) {
        isLoading.value = false
        delegate.onCreate(postId.id)
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.onError(error)
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
protocol DraftsViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func onCreate(_ id: Data)

    func onDelete()
}
