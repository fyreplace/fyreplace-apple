import Foundation
import ReactiveSwift
import SwiftProtobuf

class DraftsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftsViewModelDelegate!

    let isLoading = MutableProperty(false)

    private lazy var draftLister = ItemLister<FPPost, FPPosts, FPPostServiceNIOClient>(
        delegatingTo: delegate,
        using: postService,
        forward: false,
        type: 2
    )

    func draft(at position: Int) -> FPPost {
        return draftLister.items[position]
    }

    func create() {
        isLoading.value = true
        let request = Google_Protobuf_Empty()
        let response = postService.create(request, callOptions: .authenticated).response
        response.whenSuccess { self.onCreate($0) }
        response.whenFailure { self.onError($0) }
    }

    func delete(_ postId: Data, at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.draftsViewModel(self, didDelete: postId, at: position) { completion(true) } }
        response.whenFailure {
            self.onError($0)
            completion(false)
        }
    }

    private func onCreate(_ postId: FPId) {
        isLoading.value = false
        delegate.draftsViewModel(self, didCreate: postId.id)
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.viewModel(self, didFailWithError: error)
    }
}

extension DraftsViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { draftLister }

    func itemListView(_ listViewController: ItemListViewController, itemPreviewTypeAtPosition position: Int) -> String {
        guard let chapter = draft(at: position).chapters.first else { return "Empty" }
        return chapter.hasImage ? "Image" : "Text"
    }
}

@objc
protocol DraftsViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func draftsViewModel(_ viewModel: DraftsViewModel, didCreate id: Data)

    func draftsViewModel(_ viewModel: DraftsViewModel, didDelete id: Data, at position: Int, onCompletion handler: @escaping () -> Void)
}
