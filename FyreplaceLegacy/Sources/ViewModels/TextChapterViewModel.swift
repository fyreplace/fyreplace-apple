import Combine
import Foundation

class TextChapterViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: TextChapterViewModelDelegate?

    var textPublisher: AnyPublisher<String, Never> { $chapterText.eraseToAnyPublisher() }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }

    @Published
    var chapterText = ""

    @Published
    private(set) var isLoading = false

    func updateChapter(for postId: Data, at position: Int) {
        isLoading = true
        let request = FPChapterTextUpdate.with {
            $0.location = .with {
                $0.postID = postId
                $0.position = UInt32(position)
            }
            $0.text = chapterText
        }
        let response = chapterService.updateText(request).response
        response.whenSuccess { _ in self.delegate?.textChapterViewModel(self, didUpdateAtPosition: position, withText: self.chapterText) }
        response.whenFailure { self.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol TextChapterViewModelDelegate: ViewModelDelegate {
    func textChapterViewModel(_ viewModel: TextChapterViewModel, didUpdateAtPosition position: Int, withText text: String)
}
