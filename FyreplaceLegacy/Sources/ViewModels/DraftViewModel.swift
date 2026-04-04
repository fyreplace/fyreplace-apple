import Combine
import Foundation

class DraftViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftViewModelDelegate?

    @Published
    private(set) var post: FPPost?

    @Published
    private(set) var chapterCount = 0

    @Published
    private(set) var isLoading = false

    @Published
    private(set) var editingStatus = EditingStatus.cannotEdit

    lazy var canAddChapter = $post.combineLatest($isLoading) { post, loading in post?.chapterCount ?? 0 < 10 && !loading }

    private var postId: Data!
    private var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default
            .publisher(for: FPPost.draftWasUpdatedNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onChapterUpdated($0) }
            .store(in: &cancellables)
    }

    func retrieve(id: Data) {
        isLoading = true
        postId = id
        let request = FPId.with { $0.id = id }
        let response = postService.retrieve(request).response
        response.whenSuccess(onRetrieve)
        response.whenFailure { self.onError($0) }
    }

    func delete() {
        isLoading = true
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request).response
        response.whenSuccess { _ in self.delegate?.draftViewModel(self, didDelete: self.postId) }
        response.whenFailure { self.onError($0) }
    }

    func publish(anonymous: Bool) {
        isLoading = true
        let request = FPPublication.with {
            $0.id = postId
            $0.anonymous = anonymous
        }
        let response = postService.publish(request).response
        response.whenSuccess { _ in self.delegate?.draftViewModel(self, didPublish: self.postId, anonymously: anonymous) }
        response.whenFailure { self.onError($0) }
    }

    func createChapter(_ type: ChapterType) {
        let position = chapterCount
        chapterCount += 1
        isLoading = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.create(request).response
        response.whenSuccess { _ in self.onCreateChapter(position, type) }
        response.whenFailure { self.onError($0) }
    }

    func deleteChapter(at position: Int) {
        chapterCount -= 1
        isLoading = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.delete(request).response
        response.whenSuccess { _ in self.onDeleteChapter(position) }
        response.whenFailure { self.onError($0) }
    }

    func updateImageChapter(_ image: Data, at position: Int) {
        isLoading = true
        let stream = chapterService.updateImage()
        stream.response.whenSuccess { self.onUpdateImageChapter(position, $0) }
        stream.response.whenFailure { self.onError($0) }
        stream.upload(image, for: postId, at: position)
    }

    func moveChapter(from fromPosition: Int, to toPosition: Int) {
        isLoading = true
        let request = FPChapterRelocation.with {
            $0.postID = postId
            $0.fromPosition = UInt32(fromPosition)
            $0.toPosition = UInt32(toPosition)
        }
        let response = chapterService.move(request).response
        response.whenSuccess { _ in self.onMoveChapter(fromPosition, toPosition) }
        response.whenFailure { self.onError($0) }
    }

    func updateEditingStatus(_ editingStatus: EditingStatus) {
        self.editingStatus = editingStatus
    }

    private func onChapterUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let text = info["text"] as? String
        else { return }
        post?.chapters[position].text = text
        delegate?.draftViewModel(self, didUpdateChapterAtPosition: position, inside: postId)
    }

    private func onRetrieve(_ post: FPPost) {
        isLoading = false
        self.post = post
        chapterCount = Int(post.chapterCount)
        delegate?.draftViewModel(self, didRetrieve: post.id)
    }

    private func onCreateChapter(_ position: Int, _ type: ChapterType) {
        isLoading = false
        post?.chapters.insert(.init(), at: position)
        post?.chapterCount += 1
        delegate?.draftViewModel(self, didCreateChapterAtPosition: position, inside: postId, isText: type == .text)
    }

    private func onDeleteChapter(_ position: Int) {
        isLoading = false
        post?.chapters.remove(at: position)
        post?.chapterCount -= 1
        delegate?.draftViewModel(self, didDeleteChapterAtPosition: position, inside: postId)
    }

    private func onUpdateImageChapter(_ position: Int, _ image: FPImage) {
        isLoading = false
        post?.chapters[position].image = image
        delegate?.draftViewModel(self, didUpdateChapterAtPosition: position, inside: postId)
    }

    private func onMoveChapter(_ fromPosition: Int, _ toPosition: Int) {
        isLoading = false
        post?.chapters.remove(at: fromPosition)
        delegate?.draftViewModel(self, didMoveChapterFromPosition: fromPosition, toPosition: toPosition, inside: postId)
    }

    private func onError(_ error: Error) {
        isLoading = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol DraftViewModelDelegate: ViewModelDelegate {
    func draftViewModel(_ viewModel: DraftViewModel, didRetrieve id: Data)

    func draftViewModel(_ viewModel: DraftViewModel, didDelete id: Data)

    func draftViewModel(_ viewModel: DraftViewModel, didPublish id: Data, anonymously anonymous: Bool)

    func draftViewModel(_ viewModel: DraftViewModel, didCreateChapterAtPosition position: Int, inside id: Data, isText: Bool)

    func draftViewModel(_ viewModel: DraftViewModel, didDeleteChapterAtPosition position: Int, inside id: Data)

    func draftViewModel(_ viewModel: DraftViewModel, didUpdateChapterAtPosition position: Int, inside id: Data)

    func draftViewModel(_ viewModel: DraftViewModel, didMoveChapterFromPosition fromPosition: Int, toPosition: Int, inside id: Data)
}

enum ChapterType {
    case text
    case image
}

enum EditingStatus {
    case canEdit
    case cannotEdit
    case isEditing
}
