import Combine
import Foundation

class CommentViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: CommentViewModelDelegate?

    var textPublisher: AnyPublisher<String, Never> { $comment.eraseToAnyPublisher() }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }

    @Published
    var comment = ""

    @Published
    private(set) var isLoading = false

    func create(for postId: Data) {
        isLoading = true
        let request = FPCommentCreation.with {
            $0.postID = postId
            $0.text = comment
        }
        let response = commentService.create(request).response
        response.whenSuccess { self.delegate?.commentViewModel(self, didCreate: $0.id) }
        response.whenFailure { self.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol CommentViewModelDelegate: ViewModelDelegate {
    func commentViewModel(_ viewModel: CommentViewModel, didCreate id: Data)
}
