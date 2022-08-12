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
    var comment: UIBarButtonItem!
    @IBOutlet
    var tableHeader: PostTableHeaderView!
    @IBOutlet
    var dateFormat: DateFormat!

    var itemPosition: Int?
    var post: FPPost!
    var commentPosition: Int? { didSet { shouldScrollToComment = commentPosition != nil } }
    private var errored = false
    private var shouldScrollToComment = false
    private lazy var currentUserIsAdmin = (currentProfile?.rank ?? .citizen) > .citizen

    override var additionNotifications: [Notification.Name] {
        [FPComment.creationNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPComment.deletionNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.post.value = post
        vm.subscribed.value = post.isSubscribed
        vm.post.producer.startWithValues { [unowned self] in onPost($0) }
        vm.subscribed.producer.startWithValues { [unowned self] in onSubscribed($0) }

        if post.isPreview || post.chapterCount == 0 {
            vm.retrieve(id: post.id)
        }

        if itemPosition == nil, !post.isSubscribed {
            itemPosition = 0
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setToolbarHidden(false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        setToolbarHidden(true)
        super.viewWillDisappear(animated)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard [avatar, username, dateCreated].contains(sender as? UIView),
              let post = vm.post.value
        else { return true }

        let author = post.isAnonymous ? FPProfile() : post.author
        return author.isAvailable
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let post = vm.post.value else { return }

        if let sender = sender as? UIView,
           let userNavigationController = segue.destination as? UserNavigationViewController,
           let profile = [avatar, username, dateCreated].contains(sender)
           ? post.author
           : vm.comment(atIndex: sender.tag)?.author
        {
            userNavigationController.profile = profile
        } else if let commentNavigationController = segue.destination as? CommentNavigationViewController {
            commentNavigationController.postId = post.id
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        guard reason.userInfo?["postId"] as? Data == vm.post.value?.id else { return }
        super.addItem(item, at: indexPath, becauseOf: reason)
        let title = tableView.headerView(forSection: 0)
        title?.textLabel?.text = tableView(tableView, titleForHeaderInSection: 0)
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        guard reason.userInfo?["postId"] as? Data == vm.post.value?.id else { return }
        super.updateItem(item, at: indexPath, becauseOf: reason)
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
        presentChoiceAlert(text: "Post.Report", dangerous: true) {
            self.vm.report()
        }
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Post.Delete", dangerous: true) {
            self.vm.delete()
        }
    }

    func tryShowComment(for postId: Data, at position: Int) -> Bool {
        guard postId == vm.post.value?.id else { return false }
        var oldIndexPath: IndexPath?

        if let oldPosition = commentPosition {
            oldIndexPath = .init(row: oldPosition, section: 0)
        }

        commentPosition = position
        showComment(at: .init(row: position, section: 0), insteadOf: oldIndexPath)
        return true
    }

    private func onPost(_ post: FPPost?) {
        guard let post = post else { return }
        let currentUserOwnsPost = post.hasAuthor && post.author.id == currentProfile?.id
        report.isHidden = currentUserOwnsPost || currentUserIsAdmin
        delete.isHidden = !report.isHidden

        DispatchQueue.main.async { [self] in
            let author = post.isAnonymous ? FPProfile() : post.author
            menu.reload()
            avatar.isHidden = !author.isAvailable
            avatar.setAvatar(from: post.isAnonymous ? nil : post.author)
            username.setUsername(author)
            dateCreated.setTitle(dateFormat.string(from: post.dateCreated.date), for: .normal)
            tableHeader.setup(with: post)
        }
    }

    private func onSubscribed(_ subscribed: Bool) {
        subscribe.isHidden = subscribed
        unsubscribe.isHidden = !subscribed
        DispatchQueue.main.async { self.menu.reload() }
    }

    private func setToolbarHidden(_ hidden: Bool) {
        guard let navigationController = navigationController else { return }
        navigationController.setToolbarHidden(hidden, animated: true)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems(hidden ? nil : [space, comment, space], animated: false)
    }

    private func showComment(at indexPath: IndexPath, insteadOf oldIndexPath: IndexPath?) {
        guard indexPath.row < vm.lister.totalCount else { return }
        var paths = [indexPath]

        if let oldPath = oldIndexPath {
            paths.append(oldPath)
        }

        if vm.hasItem(atIndex: indexPath.row) {
            shouldScrollToComment = false
        }

        tableView.reloadRows(at: paths, with: .automatic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    private func acknowledgeLastVisibleComment() {
        guard let position = tableView.indexPathsForVisibleRows?.last?.row,
              let comment = vm.comment(atIndex: position)
        else { return }

        NotificationCenter.default.post(
            name: FPComment.seenNotification,
            object: self,
            userInfo: ["id": comment.id]
        )
    }
}

extension PostViewController {
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        acknowledgeLastVisibleComment()
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        acknowledgeLastVisibleComment()
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
            cell.setup(
                with: comment,
                at: indexPath.row,
                isPostAuthor: post.author.id == comment.author.id,
                isSelected: indexPath.row == commentPosition
            )
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard shouldScrollToComment, indexPath.row == commentPosition else { return }
        showComment(at: indexPath, insteadOf: nil)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comment = vm.comment(atIndex: indexPath.row),
              !comment.isDeleted
        else { return .init(actions: []) }

        let share = UIContextualAction(
            style: .normal,
            title: .tr("Post.Comment.Menu.Action.Share")
        ) { [self] _, _, completion in
            guard let post = vm.post.value ?? post else { return completion(false) }
            let provider = CommentActivityItemProvider(post: post, comment: comment, at: indexPath.row)
            let activityController = UIActivityViewController(activityItems: [provider], applicationActivities: nil)
            present(activityController, animated: true)
            completion(true)
        }

        let canDelete = currentUserIsAdmin || comment.author.id == currentProfile?.id
        let reportOrDeleteText = canDelete ? "Delete" : "Report"
        let reportOrDeleteComment = { [self] in
            if canDelete {
                vm.deleteComment(at: indexPath.row)
            } else {
                vm.reportComment(at: indexPath.row)
            }
        }

        let reportOrDelete = UIContextualAction(
            style: .destructive,
            title: .tr("Post.Comment.Menu.Action.\(reportOrDeleteText)")
        ) { _, _, completion in
            self.presentChoiceAlert(
                text: "Post.Comment.\(reportOrDeleteText)",
                dangerous: true,
                handler: reportOrDeleteComment
            )
            completion(true)
        }

        share.image = .init(called: "square.and.arrow.up.fill")
        reportOrDelete.image = .init(called: canDelete ? "trash.fill" : "exclamationmark.bubble.fill")
        return .init(actions: [share, reportOrDelete])
    }
}

extension PostViewController: PostViewModelDelegate {
    override func onFetch(count: Int, at index: Int) {
        super.onFetch(count: count, at: index)
        acknowledgeLastVisibleComment()

        if shouldScrollToComment,
           let position = commentPosition,
           position < tableView.numberOfRows(inSection: 0)
        {
            tableView.scrollToRow(at: .init(row: position, section: 0), at: .top, animated: false)
        }
    }

    func onUpdateSubscription(_ subscribed: Bool) {
        guard let position = itemPosition else { return }
        let notification = subscribed
            ? FPPost.subscriptionNotification
            : FPPost.unsubscriptionNotification
        var info: [String: Any] = ["position": position]

        if subscribed, let post = vm.post.value {
            info["item"] = post.makePreview()
        }

        NotificationCenter.default.post(name: notification, object: self, userInfo: info)
    }

    func onReport() {
        presentBasicAlert(text: "Post.Report.Success")
    }

    func onDelete() {
        guard let position = itemPosition else { return }

        NotificationCenter.default.post(
            name: FPPost.deletionNotification,
            object: self,
            userInfo: ["position": position]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func onReportComment(_ position: Int) {
        presentBasicAlert(text: "Post.Comment.Report.Success")
    }

    func onDeleteComment(_ position: Int) {
        guard let comment = vm.makeDeletedComment(fromPosition: position) else { return }
        NotificationCenter.default.post(
            name: FPComment.deletionNotification,
            object: self,
            userInfo: ["position": position, "item": comment, "postId": vm.post.value?.id as Any]
        )
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
