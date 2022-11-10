import GRPC
import ReactiveCocoa
import ReactiveSwift
import UIKit

class DraftViewController: UITableViewController {
    @IBOutlet
    var vm: DraftViewModel!
    @IBOutlet
    var imageSelector: ImageSelector!
    @IBOutlet
    var menu: MenuBarButtonItem!
    @IBOutlet
    var publish: UIBarButtonItem!
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var addText: UIButton!
    @IBOutlet
    var addImage: UIButton!

    var post: FPPost!

    private var currentChapterPosition = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "ImageChapterTableViewCell", bundle: nil), forCellReuseIdentifier: "Image")
        tableView.register(.init(nibName: "TextChapterTableViewCell", bundle: nil), forCellReuseIdentifier: "Text")
        vm.post.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onPost($0) }
        vm.chapterCount.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onChapterCount($0) }
        vm.editingStatus.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onEditingStatus($0) }
        vm.retrieve(id: post.id)
        publish.reactive.isEnabled <~ vm.chapterCount.map { $0 > 0 }
        addText.reactive.isEnabled <~ vm.canAddChapter
        addImage.reactive.isEnabled <~ vm.canAddChapter
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let chapterNavigationontroller = segue.destination as? TextChapterNavigationViewController {
            chapterNavigationontroller.post = vm.post.value
            chapterNavigationontroller.position = currentChapterPosition
            chapterNavigationontroller.text = vm.post.value?.chapters[currentChapterPosition].text
        }
    }

    @IBAction
    func onPublishPressed() {
        let alert = UIAlertController(
            title: .tr("Draft.Publish.Title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        let publishPublicly = UIAlertAction(
            title: .tr("Draft.Publish.Action.Public"),
            style: .default
        ) { _ in self.vm.publish(anonymous: false) }
        let publishAnonymously = UIAlertAction(
            title: .tr("Draft.Publish.Action.Anonymous"),
            style: .default
        ) { _ in self.vm.publish(anonymous: true) }
        let cancel = UIAlertAction(title: .tr("Cancel"), style: .cancel)
        alert.addAction(publishPublicly)
        alert.addAction(publishAnonymously)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    @IBAction
    func onEditPressed() {
        vm.updateEditingStatus(.isEditing)
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Draft.Delete", dangerous: true, handler: vm.delete)
    }

    @IBAction
    func onDonePressed() {
        vm.updateEditingStatus(.canEdit)
    }

    @IBAction
    func onAddTextPressed() {
        createChapter(.text)
    }

    @IBAction
    func onAddImagePressed() {
        createChapter(.image)
    }

    private func onPost(_ post: FPPost?) {
        guard let post = post else { return }
        let editingStatus: EditingStatus = post.chapterCount > 1 ? .canEdit : .cannotEdit

        if vm.editingStatus.value != .isEditing, editingStatus != vm.editingStatus.value {
            vm.updateEditingStatus(editingStatus)
        }

        postUpdateNotification(post)
    }

    private func onChapterCount(_ chapterCount: Int) {
        DispatchQueue.main.async {
            self.navigationItem.title = .localizedStringWithFormat(.tr("Draft.Length"), chapterCount)
        }
    }

    private func onEditingStatus(_ editingStatus: EditingStatus) {
        let shouldBeEditing = editingStatus == .isEditing

        DispatchQueue.main.async { [self] in
            if shouldBeEditing != tableView.isEditing {
                tableView.setEditing(shouldBeEditing, animated: true)
            }

            navigationItem.rightBarButtonItems = editingStatus == .isEditing
                ? [done]
                : [menu, publish]
        }
    }

    private func postUpdateNotification(_ post: FPPost) {
        NotificationCenter.default.post(
            name: FPPost.draftWasUpdatedNotification,
            object: self,
            userInfo: ["item": post]
        )
    }

    private func createChapter(_ type: ChapterType) {
        vm.createChapter(type)
    }

    private func deleteChapter(at position: Int) {
        vm.deleteChapter(at: position)
        tableView.deleteRows(at: [.init(row: position, section: 0)], with: .automatic)
    }
}

extension DraftViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.chapterCount.value
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chapter = vm.post.value!.chapters[indexPath.row]
        let identifier = chapter.hasImage ? "Image" : "Text"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        (cell as? ChapterTableViewCell)?.setup(withChapter: chapter)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chapter = vm.post.value!.chapters[indexPath.row]
        return chapter.hasImage
            ? CGFloat(chapter.image.height) * tableView.frame.width / CGFloat(chapter.image.width)
            : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        currentChapterPosition = indexPath.row
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch tableView.cellForRow(at: indexPath) {
        case let textCell as TextChapterTableViewCell:
            performSegue(withIdentifier: "Text", sender: textCell)

        case _ as ImageChapterTableViewCell:
            imageSelector.selectImage(canRemove: true)

        default:
            return
        }
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteChapter(at: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView.numberOfRows(inSection: indexPath.section) > 1
    }

    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        vm.moveChapter(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension DraftViewController: DraftViewModelDelegate {
    func draftViewModel(_ viewModel: DraftViewModel, didRetrieve id: Data) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func draftViewModel(_ viewModel: DraftViewModel, didDelete id: Data) {
        let preview = vm.post.value!.makePreview()

        NotificationCenter.default.post(
            name: FPPost.draftWasDeletedNotification,
            object: self,
            userInfo: ["item": preview]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func draftViewModel(_ viewModel: DraftViewModel, didPublish id: Data, anonymously anonymous: Bool) {
        let preview = vm.post.value!.makePreview(anonymous: anonymous)

        NotificationCenter.default.post(
            name: FPPost.draftWasPublishedNotification,
            object: self,
            userInfo: ["item": preview]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func draftViewModel(_ viewModel: DraftViewModel, didCreateChapterAtPosition position: Int, inside id: Data, isText: Bool) {
        DispatchQueue.main.async { [self] in
            tableView.insertRows(at: [.init(row: position, section: 0)], with: .automatic)
            currentChapterPosition = position

            if isText {
                performSegue(withIdentifier: "Text", sender: self)
            } else {
                imageSelector.selectImage(canRemove: false)
            }
        }
    }

    func draftViewModel(_ viewModel: DraftViewModel, didDeleteChapterAtPosition position: Int, inside id: Data) {}

    func draftViewModel(_ viewModel: DraftViewModel, didUpdateChapterAtPosition position: Int, inside id: Data) {
        DispatchQueue.main.async { [self] in
            tableView.reloadRows(at: [.init(row: position, section: 0)], with: .automatic)
        }
    }

    func draftViewModel(_ viewModel: DraftViewModel, didMoveChapterFromPosition fromPosition: Int, toPosition: Int, inside id: Data) {}

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .invalidArgument:
            switch message {
            case "payload_too_large":
                return "ImageSelector.Error.Size"

            case "chapter_empty", "post_empty":
                return "Draft.Error.\(message!.pascalized)"

            default:
                return "Error.Validation"
            }

        default:
            return "Error"
        }
    }
}

extension DraftViewController: ImageSelectorDelegate {
    var maxImageByteSize: Int { 512 * 1024 }

    func imageSelector(_ imageSelector: ImageSelector, didSelectImage image: Data?) {
        if let image = image {
            vm.updateImageChapter(image, at: currentChapterPosition)
        } else {
            deleteChapter(at: currentChapterPosition)
        }
    }

    func didNotSelectImage(_ imageSelector: ImageSelector) {
        if vm.post.value?.chapters[currentChapterPosition].hasImage == false {
            deleteChapter(at: currentChapterPosition)
        }
    }
}
