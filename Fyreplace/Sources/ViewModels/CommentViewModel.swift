import ReactiveSwift

class CommentViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: CommentViewModelDelegate!

    var text: MutableProperty<String> { comment }
    let isLoading = MutableProperty(false)
    let comment = MutableProperty("")

    private lazy var commentService = FPCommentServiceNIOClient(channel: Self.rpc.channel)

    func create(for postId: Data) {
        isLoading.value = true
        let request = FPCommentCreation.with {
            $0.postID = postId
            $0.text = comment.value
        }
        let response = commentService.create(request, callOptions: .authenticated).response
        response.whenSuccess { self.onCreate($0.id) }
        response.whenFailure { self.onError($0) }
    }

    private func onCreate(_ id: Data) {
        delegate.onCreate(id)
        let comment = FPComment.with {
            $0.id = id
            $0.text = self.comment.value
            $0.author = currentProfile!
            $0.dateCreated = .init(date: .init())
        }
        NotificationCenter.default.post(
            name: PostViewController.commentAddedNotification,
            object: self,
            userInfo: ["item": comment]
        )
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.onError(error)
    }
}

@objc
protocol CommentViewModelDelegate: ViewModelDelegate {
    func onCreate(_ id: Data)
}
