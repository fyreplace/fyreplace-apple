import GRPC
import ReactiveSwift
import UIKit

class DraftViewController: UITableViewController {
    @IBOutlet
    var vm: DraftViewModel!
    @IBOutlet
    var imageSelector: ImageSelector!
    @IBOutlet
    var menu: UIBarButtonItem!
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var addText: UIButton!
    @IBOutlet
    var addImage: UIButton!

    var itemPosition: Int!
    var post: FPPost!

    private var currentChapterPosition = -1
    private var chapterCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.post.producer.startWithValues { [weak self] in self?.onPost($0) }
        vm.retrieve(id: post.id)
        addText.reactive.isEnabled <~ vm.canAddChapter
        addImage.reactive.isEnabled <~ vm.canAddChapter
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let indexPath = IndexPath(row: currentChapterPosition, section: 0)

        if let controller = segue.destination as? TextChapterNavigationViewController,
           let cell = tableView.cellForRow(at: indexPath) as? TextChapterTableViewCell
        {
            controller.postId = post.id
            controller.position = currentChapterPosition
            controller.text = cell.content.text
        }
    }

    @IBAction
    func onEditPressed() {
        tableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItem = done
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Draft.Delete", dangerous: true, handler: vm.delete)
    }

    @IBAction
    func onDonePressed() {
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = menu
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
        postUpdateNotification()
        chapterCount = Int(post?.chapterCount ?? 0)
    }

    private func postUpdateNotification() {
        guard let position = itemPosition else { return }
        var info: [String: Any] = ["position": position]
        info["item"] = vm.post.value
        NotificationCenter.default.post(name: DraftsViewController.draftUpdatedNotification, object: self, userInfo: info)
    }

    private func createChapter(_ type: ChapterType) {
        chapterCount += 1
        vm.createChapter(type)
    }

    private func deleteChapter(at position: Int) {
        chapterCount -= 1
        vm.deleteChapter(at: position)
        tableView.deleteRows(at: [.init(row: position, section: 0)], with: .automatic)
    }
}

extension DraftViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chapter = vm.post.value!.chapters[indexPath.row]
        let identifier = chapter.hasImage ? "Image" : "Text"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        (cell as? ChapterTableViewCell)?.setup(with: chapter)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chapter = vm.post.value!.chapters[indexPath.row]
        return chapter.hasImage
            ? CGFloat(chapter.image.height) * tableView.frame.width / CGFloat(chapter.image.width)
            : super.tableView(tableView, heightForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView.cellForRow(at: indexPath) is ImageChapterTableViewCell {
            imageSelector.selectImage(canRemove: false)
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        currentChapterPosition = indexPath.row
        return indexPath
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
    func onRetrieve() {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func onDelete() {
        NotificationCenter.default.post(
            name: DraftsViewController.draftDeletedNotification,
            object: self,
            userInfo: ["position": itemPosition as Any]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func onCreateChapter(_ position: Int, _ isText: Bool) {
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

    func onDeleteChapter(_ position: Int) {}

    func onUpdateChapter(_ position: Int) {
        DispatchQueue.main.async { [self] in
            tableView.reloadRows(at: [.init(row: currentChapterPosition, section: 0)], with: .automatic)
        }
    }

    func onMoveChapter(_ fromPosition: Int, _ toPosition: Int) {}

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

extension DraftViewController: ImageSelectorDelegate {
    static let maxImageSize: Float = 0.5

    func onImageSelected(_ image: Data) {
        vm.updateImageChapter(image, at: currentChapterPosition)
    }

    func onImageRemoved() {}

    func onImageSelectionCancelled() {
        if vm.post.value?.chapters[currentChapterPosition].hasImage == false {
            deleteChapter(at: currentChapterPosition)
        }
    }
}
