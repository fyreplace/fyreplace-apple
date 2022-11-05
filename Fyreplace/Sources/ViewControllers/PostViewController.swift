import GRPC
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

    var post: FPPost!
    var selectedComment: Int? { didSet { shouldScrollToComment = selectedComment != nil } }
    var shouldScrollToComment = false
    private var errored = false
    private lazy var currentUserIsAdmin = (currentProfile?.rank ?? .citizen) > .citizen

    override var additionNotifications: [Notification.Name] {
        [FPComment.creationNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPComment.deletionNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "LoadingCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "Loader")
        tableView.register(.init(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "Comment")
        vm.post.value = post
        vm.subscribed.value = post.isSubscribed
        vm.post.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onPost($0) }
        vm.subscribed.producer
            .take(during: reactive.lifetime)
            .startWithValues { [unowned self] in onSubscribed($0) }

        if post.isPreview || post.chapterCount == 0 {
            vm.retrieve(id: post.id)
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
        guard [avatar, username, dateCreated].contains(sender as? UIView) else { return true }
        let author = vm.post.value.isAnonymous ? FPProfile() : vm.post.value.author
        return author.isAvailable
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let sender = sender as? UIView,
           let userNavigationController = segue.destination as? UserNavigationViewController,
           let profile = [avatar, username, dateCreated].contains(sender)
           ? vm.post.value.author
           : vm.comment(atIndex: sender.tag)?.author
        {
            userNavigationController.profile = profile
        } else if let commentNavigationController = segue.destination as? CommentNavigationViewController {
            commentNavigationController.postId = vm.post.value.id
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        guard reason.userInfo?["postId"] as? Data == vm.post.value.id else { return }
        super.addItem(item, at: indexPath, becauseOf: reason)
        let title = tableView.headerView(forSection: 0)
        title?.textLabel?.text = tableView(tableView, titleForHeaderInSection: 0)

        if reason.userInfo?["byCurrentUser"] as? Bool == true {
            _ = tryShowComment(
                for: vm.post.value.id,
                at: listDelegate.lister.totalCount - 1,
                selected: false
            )
        }
    }

    override func updateItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        guard reason.userInfo?["postId"] as? Data == vm.post.value.id else { return }
        super.updateItem(item, at: indexPath, becauseOf: reason)
    }

    @IBAction
    func onSharePressed() {
        let provider = PostActivityItemProvider(post: vm.post.value)
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

    func tryShowComment(for postId: Data, at position: Int, selected: Bool = true) -> Bool {
        guard postId == vm.post.value.id else { return false }
        var oldPosition: Int?

        if selected {
            if let old = selectedComment {
                oldPosition = old
            }

            selectedComment = position
        }

        showComment(at: position, insteadOf: oldPosition)
        return true
    }

    func tryHandleCommentCreation(for postId: Data) -> Bool {
        guard postId == vm.post.value.id else { return false }
        let position = tableView.indexPathsForVisibleRows?.last?.row ?? -1

        if position == vm.lister.totalCount - 1 {
            showComment(at: position, insteadOf: nil)
        } else {
            return false
        }

        return true
    }

    func showUnreadComments() {
        let commentsRead = Int(vm.post.value.commentsRead)
        guard commentsRead > 0 else { return }
        showComment(at: commentsRead, insteadOf: nil)
    }

    private func onPost(_ post: FPPost) {
        let currentUserOwnsPost = post.hasAuthor && post.author.id == currentProfile?.id
        report.isConcealed = currentUserOwnsPost || currentUserIsAdmin
        delete.isConcealed = !report.isConcealed

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
        subscribe.isConcealed = subscribed
        unsubscribe.isConcealed = !subscribed
        DispatchQueue.main.async { self.menu.reload() }
    }

    private func setToolbarHidden(_ hidden: Bool) {
        guard let navigationController = navigationController else { return }
        navigationController.setToolbarHidden(hidden, animated: true)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems(hidden ? nil : [space, comment, space], animated: false)
    }

    private func showComment(at position: Int, insteadOf oldPosition: Int?) {
        let indexPath = IndexPath(row: position, section: 0)
        let oldIndexPath: IndexPath?

        if let oldPosition = oldPosition {
            oldIndexPath = .init(row: oldPosition, section: 0)
        } else {
            oldIndexPath = nil
        }

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
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    private func acknowledgeComment(_ comment: FPComment, at position: Int) {
        NotificationCenter.default.post(
            name: FPComment.seenNotification,
            object: self,
            userInfo: [
                "id": comment.id,
                "postId": vm.post.value.id,
                "commentsLeft": vm.lister.totalCount - 1 - position,
            ]
        )
    }

    private func isCommentHighlighted(at position: Int) -> Bool {
        return vm.post.value.isSubscribed && position >= vm.post.value.commentsRead
    }
}

extension PostViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            guard shouldScrollToComment else { return }

            if let position = selectedComment {
                showComment(at: position, insteadOf: nil)
            } else if vm.post.value.commentsRead > 0 {
                showUnreadComments()
            }
        }

        return count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return .tr(vm.lister.totalCount > 0 ? "Post.Comments.Title" : "Post.Comments.Empty.Title")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let cell = cell as? CommentTableViewCell else { return cell }
        cell.dateFormat = dateFormat
        cell.delegate = self

        if let comment = vm.comment(atIndex: indexPath.row) {
            cell.setup(
                withComment: comment,
                at: indexPath.row,
                isPostAuthor: vm.post.value.author.id == comment.author.id,
                isSelected: indexPath.row == selectedComment,
                isHighlighted: isCommentHighlighted(at: indexPath.row)
            )
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let comment = vm.comment(atIndex: indexPath.row),
           isCommentHighlighted(at: indexPath.row)
        {
            acknowledgeComment(comment, at: indexPath.row)
        }

        guard shouldScrollToComment else { return }

        if indexPath.row == selectedComment {
            showComment(at: indexPath.row, insteadOf: nil)
        } else if indexPath.row == vm.post.value.commentsRead, vm.post.value.commentsRead > 0 {
            showUnreadComments()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let comment = vm.comment(atIndex: indexPath.row),
              !comment.isDeleted
        else { return .init(actions: []) }

        let share = UIContextualAction(
            style: .normal,
            title: .tr("Post.Comment.Menu.Action.Share")
        ) { [self] _, _, completion in
            let provider = CommentActivityItemProvider(post: vm.post.value, comment: comment, at: indexPath.row)
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
    override func onFetch(count: Int, at index: Int, oldTotal: Int, newTotal: Int) {
        if oldTotal == 0,
           vm.post.value.commentsRead > 0,
           vm.post.value.commentsRead < vm.lister.totalCount
        {
            shouldScrollToComment = true
        }

        super.onFetch(count: count, at: index, oldTotal: oldTotal, newTotal: newTotal)

        if shouldScrollToComment,
           let position = selectedComment,
           position < tableView.numberOfRows(inSection: 0)
        {
            tableView.scrollToRow(at: .init(row: position, section: 0), at: .top, animated: false)
        }
    }

    func onRetrieve() {}

    func onUpdateSubscription(_ subscribed: Bool) {
        NotificationCenter.default.post(
            name: subscribed
                ? FPPost.subscriptionNotification
                : FPPost.unsubscriptionNotification,
            object: self,
            userInfo: ["item": vm.post.value.makePreview()]
        )
    }

    func onReport() {
        presentBasicAlert(text: "Post.Report.Success")
    }

    func onDelete() {
        NotificationCenter.default.post(
            name: FPPost.deletionNotification,
            object: self,
            userInfo: ["item": vm.post.value.makePreview()]
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
            userInfo: ["item": comment, "postId": vm.post.value.id]
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

extension PostViewController: CommentTableViewCellDelegate {
    func commentTableViewCell(_ cell: CommentTableViewCell, didClickOnView view: UIView) {
        performSegue(withIdentifier: "User", sender: view)
    }
}
