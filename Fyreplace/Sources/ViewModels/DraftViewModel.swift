import Foundation
import ReactiveSwift

class DraftViewModel: ViewModel {
    @IBOutlet
    weak var delegate: DraftViewModelDelegate!

    let post = MutableProperty<FPPost?>(nil)
    let isLoading = MutableProperty<Bool>(false)
    lazy var canAddChapter = post
        .combineLatest(with: isLoading)
        .map { post, loading in post?.chapterCount ?? 0 < 10 && !loading }
    let editingStatus = MutableProperty<EditingStatus>(.cannotEdit)

    private var postId: Data!
    private lazy var postService = FPPostServiceClient(channel: Self.rpc.channel)
    private lazy var chapterService = FPChapterServiceClient(channel: Self.rpc.channel)

    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.reactive
            .notifications(forName: DraftViewController.chapterUpdated)
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
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let request = FPId.with { $0.id = postId }
        let response = postService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onDelete() }
        response.whenFailure(delegate.onError(_:))
    }

    func createChapter(_ type: ChapterType) {
        guard let position = post.value?.chapters.count else { return }
        isLoading.value = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.create(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onCreateChapter(position, type) }
        response.whenFailure(delegate.onError(_:))
    }

    func deleteChapter(at position: Int) {
        isLoading.value = true
        let request = FPChapterLocation.with {
            $0.postID = postId
            $0.position = UInt32(position)
        }
        let response = chapterService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDeleteChapter(position) }
        response.whenFailure(delegate.onError(_:))
    }

    func updateImageChapter(_ image: Data, at position: Int) {
        isLoading.value = true
        let stream = chapterService.updateImage(callOptions: .authenticated)
        stream.response.whenSuccess { self.onUpdateImageChapter(position, $0) }
        stream.response.whenFailure(delegate.onError(_:))
        stream.upload(image, for: postId, at: position)
    }

    func moveChapter(from fromPosition: Int, to toPosition: Int) {
        let request = FPChapterRelocation.with {
            $0.postID = postId
            $0.fromPosition = UInt32(fromPosition)
            $0.toPosition = UInt32(toPosition)
        }
        let response = chapterService.move(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onMoveChapter(fromPosition, toPosition) }
        response.whenFailure(delegate.onError(_:))
    }

    func updateEditingStatus(_ editingStatus: EditingStatus) {
        self.editingStatus.value = editingStatus
    }

    private func onChapterUpdated(_ notification: Notification) {
        guard let info = notification.userInfo,
              let position = info["position"] as? Int,
              let text = info["text"] as? String
        else { return }
        isLoading.value = false
        post.modify { $0?.chapters[position].text = text }
        delegate.onUpdateChapter(position)
    }

    private func onRetrieve(_ post: FPPost) {
        isLoading.value = false
        self.post.value = post
        delegate.onRetrieve()
    }

    private func onCreateChapter(_ position: Int, _ type: ChapterType) {
        post.modify {
            $0?.chapters.insert(.init(), at: position)
            $0?.chapterCount += 1
        }
        delegate.onCreateChapter(position, type == .text)
    }

    private func onDeleteChapter(_ position: Int) {
        isLoading.value = false
        post.modify {
            $0?.chapters.remove(at: position)
            $0?.chapterCount -= 1
        }
        delegate.onDeleteChapter(position)
    }

    private func onUpdateImageChapter(_ position: Int, _ image: FPImage) {
        isLoading.value = false
        post.modify { $0?.chapters[position].image = image }
        delegate.onUpdateChapter(position)
    }

    private func onMoveChapter(_ fromPosition: Int, _ toPosition: Int) {
        post.modify {
            guard var chapters = $0?.chapters else { return }
            chapters.insert(chapters.remove(at: fromPosition), at: toPosition)
            $0?.chapters = chapters
        }
        delegate.onMoveChapter(fromPosition, toPosition)
    }
}

@objc
protocol DraftViewModelDelegate: ViewModelDelegate {
    func onRetrieve()

    func onDelete()

    func onCreateChapter(_ position: Int, _ isText: Bool)

    func onDeleteChapter(_ position: Int)

    func onUpdateChapter(_ position: Int)

    func onMoveChapter(_ fromPosition: Int, _ toPosition: Int)
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
