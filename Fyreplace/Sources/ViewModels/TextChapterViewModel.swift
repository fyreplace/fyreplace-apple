import Foundation
import ReactiveSwift

class TextChapterViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: TextChapterViewModelDelegate!

    var text: MutableProperty<String> { chapterText }
    let isLoading = MutableProperty(false)
    let chapterText = MutableProperty("")

    private lazy var chapterService = FPChapterServiceNIOClient(channel: Self.rpc.channel)

    func setInitialChapterText(_ text: String) {
        chapterText.value = text
    }

    func updateChapter(for postId: Data, at position: Int) {
        isLoading.value = true
        let request = FPChapterTextUpdate.with {
            $0.location = .with {
                $0.postID = postId
                $0.position = UInt32(position)
            }
            $0.text = chapterText.value
        }
        let response = chapterService.updateText(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onUpdateChapter(self.chapterText.value) }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.onError(error)
    }
}

@objc
protocol TextChapterViewModelDelegate: ViewModelDelegate {
    func onUpdateChapter(_ text: String)
}
