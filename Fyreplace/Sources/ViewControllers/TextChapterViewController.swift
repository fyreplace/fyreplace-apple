import GRPC
import ReactiveSwift
import UIKit

class TextChapterViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel! { vm }
    override var maxContentLength: Int { 500 }

    @IBOutlet
    var vm: TextChapterViewModel!

    var post: FPPost!
    var position: Int!
    var text: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = text
        vm.setInitialChapterText(text)
        vm.chapterText <~ content.reactive.continuousTextValues.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    override func onDonePressed() {
        vm.updateChapter(for: post.id, at: position)
    }
}

extension TextChapterViewController: TextChapterViewModelDelegate {
    func onUpdateChapter(_ text: String) {
        NotificationCenter.default.post(
            name: FPPost.draftUpdateNotification,
            object: self,
            userInfo: ["item": post!, "position": position!, "text": text]
        )

        DispatchQueue.main.async { self.dismiss(animated: true) }
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
