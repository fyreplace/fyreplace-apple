import GRPC
import ReactiveCocoa
import ReactiveSwift
import UIKit

class CommentViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel! { vm }
    override var maxContentLength: Int { 500 }

    @IBOutlet
    var vm: CommentViewModel!

    var postId: Data!

    override func viewDidLoad() {
        super.viewDidLoad()
        done.reactive.isEnabled <~ vm.comment.map(\.isEmpty).negate()
        vm.comment <~ content.reactive.continuousTextValues.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    override func onDonePressed() {
        vm.create(for: postId)
    }
}

extension CommentViewController: CommentViewModelDelegate {
    func onCreate(_ id: Data) {
        DispatchQueue.main.async { [unowned self] in dismiss(animated: true) }
    }

    func errorKey(for code: Int, with message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .permissionDenied:
            return "Comment.Error.Blocked"

        case .invalidArgument:
            return content.text.count > maxContentLength
                ? "Comment.Error.TooLong"
                : "Error.Validation"

        default:
            return "Error"
        }
    }
}
