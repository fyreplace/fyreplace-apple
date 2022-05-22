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
        vm.chapterText <~ content.reactive.continuousTextValues
    }

    override func onDonePressed() {
        vm.updateChapter(for: postId, at: position)
    }
}

extension TextChapterViewController: TextChapterViewModelDelegate {
    func onUpdateChapter(_ text: String) {
        NotificationCenter.default.post(name: DraftViewController.chapterUpdated, object: self, userInfo: ["position": position ?? 0, "text": text])
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }
}
