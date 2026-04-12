import Combine
import GRPC
import UIKit

class CommentViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel { vm }
    override var maxContentLength: Int { 1500 }

    @IBOutlet
    var vm: CommentViewModel!

    var postId: Data!
    var text: String!
    private var isDone = false
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = text

        content
            .textPublisher
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .assign(to: &vm.$comment)
        vm.$comment
            .map { !$0.isEmpty }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: done)
            .store(in: &cancellables)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if !isDone {
            NotificationCenter.default.post(
                name: FPComment.wasSavedNotification,
                object: self,
                userInfo: ["text": vm.comment]
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
            $0.text = vm.comment
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
