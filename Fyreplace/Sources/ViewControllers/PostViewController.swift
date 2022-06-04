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

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.subscribed.value = post.isSubscribed
        vm.retrieve(id: post.id)
        vm.post.producer.startWithValues { [weak self] in self?.onPost($0) }
        vm.subscribed.producer.startWithValues { [weak self] in self?.onSubscribed($0) }
        avatar.isHidden = !post.author.isAvailable
        avatar.setAvatar(post.isAnonymous ? "" : post.author.avatar.url)
        username.isEnabled = post.author.isAvailable
        username.setUsername(post.author)
        dateCreated.isEnabled = post.author.isAvailable
        dateCreated.setTitle(dateFormat.string(from: post.dateCreated.date), for: .normal)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let userNavigationController = segue.destination as? UserNavigationViewController {
            userNavigationController.profile = post.author
        }
    }

    @IBAction
    func onSharePressed() {
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
            menu.reload()
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
           let comment = vm.comment(atIndex: indexPath.row)
        {
            cell.setup(with: comment, isPostAuthor: post.author.id == comment.author.id)
        }

        return cell
    }
}

extension PostViewController: PostViewModelDelegate {
    func onUpdateSubscription(_ subscribed: Bool) {
        guard let position = itemPosition else { return }
        let notification = subscribed
            ? ArchiveViewController.postAddedNotification
            : ArchiveViewController.postDeletedNotification
        var info: [String: Any] = ["position": position]

        if subscribed {
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
        return "Error"
    }
}

extension PostViewController: DynamicStackViewDelegate {
    func boundsDidUpdate(_ bounds: CGRect) {
        tableHeader.resize()
        tableView.tableHeaderView = tableHeader
    }
}
