import GRPC
import Kingfisher
import ReactiveSwift
import UIKit

class PostViewController: ItemRandomAccessListViewController {
    @IBOutlet
    var vm: PostViewModel!
    @IBOutlet
    var menu: MenuBarButtonItem!
    @IBOutlet
    var subscribe: ActionBarButtonItem!
    @IBOutlet
    var unsubscribe: ActionBarButtonItem!
    @IBOutlet
    var report: ActionBarButtonItem!
    @IBOutlet
    var delete: ActionBarButtonItem!
    @IBOutlet
    var avatar: UIButton!
    @IBOutlet
    var username: UIButton!
    @IBOutlet
    var dateCreated: UIButton!
    @IBOutlet
    var tableHeader: PostTableHeaderView!
    @IBOutlet
    var dateFormat: DateFormat!

    var itemPosition: Int?
    var post: FPPost!
    private var errored = false

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.post.value = post
        vm.subscribed.value = post.isSubscribed
        vm.post.producer.startWithValues { [weak self] in self?.onPost($0) }
        vm.subscribed.producer.startWithValues { [weak self] in self?.onSubscribed($0) }

        if post.isPreview || post.chapterCount == 0 {
            vm.retrieve(id: post.id)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let userNavigationController = segue.destination as? UserNavigationViewController,
           let post = vm.post.value
        {
            userNavigationController.profile = post.author
        }
    }

    @IBAction
    func onSharePressed() {
        let post = vm.post.value ?? post!
        let provider = PostActivityItemProvider(post: post)
        let activityController = UIActivityViewController(activityItems: [provider], applicationActivities: nil)
        present(activityController, animated: true)
    }

    @IBAction
    func onSubscribePressed() {
        vm.updateSubscription(subscribed: true)
    }

    @IBAction
    func onUnsubscribePressed() {
        vm.updateSubscription(subscribed: false)
    }

    @IBAction
    func onReportPressed() {
        presentChoiceAlert(text: "Post.Report", dangerous: true) { self.vm.report() }
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Post.Delete", dangerous: true) { self.vm.delete() }
    }

    private func onPost(_ post: FPPost?) {
        guard let post = post else { return }
        let currentProfile = getCurrentProfile()
        let currentUserOwnsPost = post.hasAuthor && post.author.id == currentProfile?.id
        let currentUserIsAdmin = (currentProfile?.rank ?? .citizen) > .citizen
        report.isHidden = currentUserOwnsPost || currentUserIsAdmin
        delete.isHidden = !report.isHidden

        DispatchQueue.main.async { [self] in
            let author = post.isAnonymous ? FPProfile() : post.author
            menu.reload()
            avatar.isHidden = !author.isAvailable
            avatar.setAvatar(post.isAnonymous ? "" : post.author.avatar.url)
            username.isEnabled = author.isAvailable
            username.setUsername(author)
            dateCreated.isEnabled = author.isAvailable
            dateCreated.setTitle(dateFormat.string(from: post.dateCreated.date), for: .normal)
            tableHeader.setup(with: post)
            tableView.reloadData()
        }
    }

    private func onSubscribed(_ subscribed: Bool) {
        subscribe.isHidden = subscribed
        unsubscribe.isHidden = !subscribed
        DispatchQueue.main.async { self.menu.reload() }
    }
}

extension PostViewController {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return .tr(vm.lister.itemCount > 0 ? "Post.Comments.Title" : "Post.Comments.Empty.Title")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let cell = cell as? CommentTableViewCell,
           let comment = vm.comment(atIndex: indexPath.row),
           let post = vm.post.value
        {
            cell.setup(with: comment, isPostAuthor: post.author.id == comment.author.id)
        }

        return cell
    }
}

extension PostViewController: PostViewModelDelegate {
    func onUpdateSubscription(_ subscribed: Bool) {
        let position = itemPosition ?? 0
        let notification = subscribed
            ? ArchiveViewController.postAddedNotification
            : ArchiveViewController.postDeletedNotification
        var info: [String: Any] = ["position": position]

        if subscribed, let post = vm.post.value {
            info["item"] = post
        }

        NotificationCenter.default.post(name: notification, object: self, userInfo: info)
    }

    func onReport() {
        presentBasicAlert(text: "Post.Report.Success")
    }

    func onDelete() {
        NotificationCenter.default.post(
            name: ArchiveViewController.postDeletedNotification,
            object: self,
            userInfo: ["position": itemPosition as Any]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func errorKey(for code: Int, with message: String?) -> String? {
        guard !errored else { return nil }
        errored = true

        switch GRPCStatus.Code(rawValue: code)! {
        case .invalidArgument, .notFound:
            NotificationCenter.default.post(name: FPPost.notFoundNotification, object: self)
            return "Post.Error.NotFound"

        default:
            return "Error"
        }
    }
}

extension PostViewController: DynamicStackViewDelegate {
    func boundsDidUpdate(_ bounds: CGRect) {
        tableHeader.resize()
        tableView.tableHeaderView = tableHeader
    }
}
