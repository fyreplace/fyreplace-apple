import GRPC
import ReactiveCocoa
import ReactiveSwift
import UIKit

class CommentViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel! { vm }
    override var maxContentLength: Int { 1500 }

    @IBOutlet
    var vm: CommentViewModel!

    var postId: Data!
    var text: String!
    private var isDone = false

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = text
        done.reactive.isEnabled <~ vm.comment.map(\.isEmpty).negate()
        vm.comment <~ content.reactive.continuousTextValues.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        vm.comment.value = text
    }

    override func viewDidDisappear(_ animated: Bool) {
        if !isDone {
            NotificationCenter.default.post(
                name: FPComment.wasSavedNotification,
                object: self,
                userInfo: ["text": vm.text.value]
            )
        }

        super.viewDidDisappear(animated)
    }

    override func onDonePressed() {
        vm.create(for: postId)
    }
}

extension CommentViewController: CommentViewModelDelegate {
    func commentViewModel(_ viewModel: CommentViewModel, didCreate id: Data) {
        let comment = FPComment.with {
            $0.id = id
            $0.text = vm.comment.value
            $0.author = currentProfile!
            $0.dateCreated = .init(date: .init())
        }
        NotificationCenter.default.post(
            name: FPComment.wasCreatedNotification,
            object: self,
            userInfo: ["item": comment, "postId": postId!, "byCurrentUser": true]
        )

        isDone = true
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .permissionDenied:
            switch message {
            case "caller_blocked":
                return "Comment.Error.Blocked"

            default:
                return "Error.Permission"
            }

        case .invalidArgument:
            return content.text.count > maxContentLength
                ? "Comment.Error.TooLong"
                : "Error.Validation"

        default:
            return "Error"
        }
    }
}
