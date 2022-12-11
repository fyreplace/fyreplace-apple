import Foundation
import ReactiveSwift

class DraftViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftViewModelDelegate?

    let post = MutableProperty<FPPost?>(nil)
    let chapterCount = MutableProperty<Int>(0)
    let isLoading = MutableProperty<Bool>(false)
    lazy var canAddChapter = post
        .combineLatest(with: isLoading)
        .map { post, loading in post?.chapterCount ?? 0 < 10 && !loading }
    let editingStatus = MutableProperty<EditingStatus>(.cannotEdit)

    private var postId: Data!

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.reactive
            .notifications(forName: FPPost.draftWasUpdatedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onChapterUpdated($0) }
    }

    func retrieve(id: Data) {
        isLoading.value = true
        postId = id
        let request = FPId.with { $0.id = id }
        let response = postService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure { self.onError($0) }
    }

    func delete() {
        isLoading.value = true
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.draftViewModel(self, didDelete: self.postId) }
        response.whenFailure { self.onError($0) }
    }

    func publish(anonymous: Bool) {
        isLoading.value = true
        let request = FPPublication.with {
            $0.id = postId
            $0.anonymous = anonymous
        }
        let response = postService.publish(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.draftViewModel(self, didPublish: self.postId, anonymously: anonymous) }
        response.whenFailure { self.onError($0) }
    }

    func createChapter(_ type: ChapterType) {
        guard let position = post.value?.chapters.count else { return }
        chapterCount.value += 1
        isLoading.value = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.create(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onCreateChapter(position, type) }
        response.whenFailure { self.onError($0) }
    }

    func deleteChapter(at position: Int) {
        post.modify {
            $0?.chapters.remove(at: position)
            $0?.chapterCount -= 1
        }
        chapterCount.value -= 1
        isLoading.value = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDeleteChapter(position) }
        response.whenFailure { self.onError($0) }
    }

    func updateImageChapter(_ image: Data, at position: Int) {
        isLoading.value = true
        let stream = chapterService.updateImage(callOptions: .authenticated)
        stream.response.whenSuccess { self.onUpdateImageChapter(position, $0) }
        stream.response.whenFailure { self.onError($0) }
        stream.upload(image, for: postId, at: position)
    }

    func moveChapter(from fromPosition: Int, to toPosition: Int) {
        isLoading.value = true
        let request = FPChapterRelocation.with {
            $0.postID = postId
            $0.fromPosition = UInt32(fromPosition)
            $0.toPosition = UInt32(toPosition)
        }
        let response = chapterService.move(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onMoveChapter(fromPosition, toPosition) }
        response.whenFailure { self.onError($0) }
    }

    func updateEditingStatus(_ editingStatus: EditingStatus) {
        self.editingStatus.value = editingStatus
    }

    private func onChapterUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let text = info["text"] as? String
        else { return }
        post.modify { $0?.chapters[position].text = text }
        delegate?.draftViewModel(self, didUpdateChapterAtPosition: position, inside: postId)
    }

    private func onRetrieve(_ post: FPPost) {
        isLoading.value = false
        chapterCount.value = Int(post.chapterCount)
        self.post.value = post
        delegate?.draftViewModel(self, didRetrieve: post.id)
    }

    private func onCreateChapter(_ position: Int, _ type: ChapterType) {
        isLoading.value = false
        post.modify {
            $0?.chapters.insert(.init(), at: position)
            $0?.chapterCount += 1
        }
        delegate?.draftViewModel(self, didCreateChapterAtPosition: position, inside: postId, isText: type == .text)
    }

    private func onDeleteChapter(_ position: Int) {
        isLoading.value = false
        delegate?.draftViewModel(self, didDeleteChapterAtPosition: position, inside: postId)
    }

    private func onUpdateImageChapter(_ position: Int, _ image: FPImage) {
        isLoading.value = false
        post.modify { $0?.chapters[position].image = image }
        delegate?.draftViewModel(self, didUpdateChapterAtPosition: position, inside: postId)
    }

    private func onMoveChapter(_ fromPosition: Int, _ toPosition: Int) {
        isLoading.value = false
        post.modify {
            guard var chapters = $0?.chapters else { return }
            chapters.insert(chapters.remove(at: fromPosition), at: toPosition)
            $0?.chapters = chapters
        }
        delegate?.draftViewModel(self, didMoveChapterFromPosition: fromPosition, toPosition: toPosition, inside: postId)
    }

    private func onError(_ error: Error) {
        isLoading.value = false
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
