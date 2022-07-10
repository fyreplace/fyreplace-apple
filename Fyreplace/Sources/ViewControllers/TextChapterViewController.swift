import GRPC
import ReactiveSwift
import UIKit

class TextChapterViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel! { vm }
    override var maxContentLength: Int { 500 }

    @IBOutlet
    var vm: TextChapterViewModel!

    var postId: Data!
    var position: Int!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = text
        vm.setInitialChapterText(text)
        vm.chapterText <~ content.reactive.continuousTextValues.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    override func onDonePressed() {
        vm.updateChapter(for: postId, at: position)
    }
}

extension TextChapterViewController: TextChapterViewModelDelegate {
    func onUpdateChapter(_ text: String) {
        NotificationCenter.default.post(
            name: DraftViewController.chapterUpdated,
            object: self,
            userInfo: ["position": position ?? 0, "text": text]
        )

        DispatchQueue.main.async { [unowned self] in dismiss(animated: true) }
    }

    func errorKey(for code: Int, with message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .invalidArgument:
            return "TextChapter.Error.ChapterTooLong"
        default:
            return "Error"
        }
    }
}
