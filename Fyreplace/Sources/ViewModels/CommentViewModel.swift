import Foundation
import ReactiveSwift

class CommentViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: CommentViewModelDelegate?

    var text: MutableProperty<String> { comment }
    let isLoading = MutableProperty(false)
    let comment = MutableProperty("")

    func create(for postId: Data) {
        isLoading.value = true
        let request = FPCommentCreation.with {
            $0.postID = postId
            $0.text = comment.value
        }
        let response = commentService.create(request).response
        response.whenSuccess { self.delegate?.commentViewModel(self, didCreate: $0.id) }
        response.whenFailure { self.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol CommentViewModelDelegate: ViewModelDelegate {
    func commentViewModel(_ viewModel: CommentViewModel, didCreate id: Data)
}
