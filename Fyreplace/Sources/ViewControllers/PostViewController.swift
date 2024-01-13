import GRPC
import ReactiveSwift
import SDWebImage
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
    var comment: UIButton!
    @IBOutlet
    var tableHeader: PostTableHeaderView!
    @IBOutlet
    var dateFormat: DateFormat!

    var post: FPPost!
    var selectedComment: Int? { didSet { shouldScrollToComment = selectedComment != nil } }
    var shouldScrollToComment = false
    private var errored = false
    private lazy var currentUserIsAdmin = (currentProfile?.rank ?? .citizen) > .citizen
    private var savedComment = ""

    override var additionNotifications: [Notification.Name] {
        [FPComment.wasCreatedNotification]
    }

    override var updateNotifications: [Notification.Name] {
        [FPComment.wasDeletedNotification]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        avatar.sd_imageTransition = .fade
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

        NotificationCenter.default.reactive
            .notifications(forName: FPComment.wasSavedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onCommentWasSaved($0) }

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
           : vm.comment(at: sender.tag)?.author
        {
            userNavigationController.profile = profile
        } else if let commentNavigationController = segue.destination as? CommentNavigationViewController {
            commentNavigationController.postId = vm.post.value.id
            commentNavigationController.text = savedComment
        }
    }

    override func addItem(_ item: Any, at indexPath: IndexPath, becauseOf reason: Notification) {
        guard reason.userInfo?["postId"] as? Data == vm.post.value.id else { return }
        super.addItem(item, at: indexPath, becauseOf: reason)
        let title = tableView.headerView(forSection: 0)
        title?.textLabel?.text = tableView(tableView, titleForHeaderInSection: 0)

        guard reason.userInfo?["byCurrentUser"] as? Bool == true else { return }
        _ = tryShowComment(
            for: vm.post.value.id,
            at: listDelegate.lister.totalCount - 1,
            selected: false
        )
        savedComment = ""
        vm.subscribed.value = true
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
        presentChoiceAlert(text: "Post.Report", dangerous: true) { yes in
            guard yes else { return }
            self.vm.report()
        }
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Post.Delete", dangerous: true) { yes in
            guard yes else { return }
            self.vm.delete()
        }
    }

    func tryShowComment(for postId: Data, at position: Int, selected: Bool = true) -> Bool {
        guard postId == vm.post.value.id else { return false }
        var oldPosition: Int?

        if selected {
            if let selectedComment {
                oldPosition = selectedComment
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

    private func onCommentWasSaved(_ notification: Notification) {
        guard let info = notification.userInfo,
              let text = info["text"] as? String
        else { return }
        savedComment = text
    }

    private func setToolbarHidden(_ hidden: Bool) {
        guard let navigationController = navigationController else { return }
        navigationController.setToolbarHidden(hidden, animated: true)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setToolbarItems(hidden || currentUser == nil ? nil : [space, .init(customView: comment), space], animated: false)
    }

    private func showComment(at position: Int, insteadOf oldPosition: Int?) {
        let indexPath = IndexPath(row: position, section: 0)
        let oldIndexPath: IndexPath?

        if let oldPosition {
            oldIndexPath = .init(row: oldPosition, section: 0)
        } else {
            oldIndexPath = nil
        }

        guard indexPath.row < vm.lister.totalCount else { return }
        var paths = [indexPath]

        if let oldIndexPath {
            paths.append(oldIndexPath)
        }

        if vm.itemRandomAccessListView(self, hasItemAtPosition: indexPath.row) {
            shouldScrollToComment = false
        }

        tableView.reloadRows(at: paths, with: .automatic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }

    private func isCommentHighlighted(at position: Int) -> Bool {
        return vm.post.value.isSubscribed && position >= vm.post.value.commentsRead
    }
}

extension PostViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return vm.post.value.isPreview ? 0 : super.numberOfSections(in: tableView)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = super.tableView(tableView, numberOfRowsInSection: section)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            guard shouldScrollToComment else { return }

            if let selectedComment {
                showComment(at: selectedComment, insteadOf: nil)
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

        if let comment = vm.comment(at: indexPath.row) {
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
        if isCommentHighlighted(at: indexPath.row) {
            vm.acknowledgeComment(at: indexPath.row)
        }

        guard shouldScrollToComment else { return }

        if indexPath.row == selectedComment {
            showComment(at: indexPath.row, insteadOf: nil)
        } else if indexPath.row == vm.post.value.commentsRead, vm.post.value.commentsRead > 0 {
            showUnreadComments()
        }
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let currentProfile,
              let comment = vm.comment(at: indexPath.row),
              !comment.isDeleted
        else { return nil }

        let share = UIContextualAction(
            style: .normal,
            title: .tr("Post.Comment.Menu.Action.Share")
        ) { [self] _, _, completion in
            let provider = CommentActivityItemProvider(post: vm.post.value, comment: comment, at: indexPath.row)
            let activityController = UIActivityViewController(activityItems: [provider], applicationActivities: nil)
            present(activityController, animated: true)
            completion(true)
        }

        let canDelete = currentUserIsAdmin || comment.author.id == currentProfile.id
        let reportOrDeleteText = canDelete ? "Delete" : "Report"
        let reportOrDelete = UIContextualAction(
            style: .destructive,
            title: .tr("Post.Comment.Menu.Action.\(reportOrDeleteText)")
        ) { _, _, completion in
            self.presentChoiceAlert(
                text: "Post.Comment.\(reportOrDeleteText)",
                dangerous: true,
                handler: { [self] yes in
                    guard yes else { return completion(false) }

                    if canDelete {
                        vm.deleteComment(at: indexPath.row, onCompletion: completion)
                    } else {
                        vm.reportComment(at: indexPath.row, onCompletion: completion)
                    }
                }
            )
        }

        share.image = .init(called: "square.and.arrow.up.fill")
        reportOrDelete.image = .init(called: canDelete ? "trash.fill" : "exclamationmark.bubble.fill")
        return .init(actions: [share, reportOrDelete])
    }
}

extension PostViewController: PostViewModelDelegate {
    override func itemRandomAccessLister(_ itemLister: ItemRandomAccessListerProtocol, didFetch count: Int, at position: Int, oldTotal: Int, newTotal: Int) {
        if oldTotal == 0,
           vm.post.value.commentsRead > 0,
           vm.post.value.commentsRead < vm.lister.totalCount
        {
            shouldScrollToComment = true
        }

        super.itemRandomAccessLister(itemLister, didFetch: count, at: position, oldTotal: oldTotal, newTotal: newTotal)

        if shouldScrollToComment,
           let position = selectedComment,
           position < tableView.numberOfRows(inSection: 0)
        {
            tableView.scrollToRow(at: .init(row: position, section: 0), at: .top, animated: false)
        }
    }

    func postViewModel(_ viewModel: PostViewModel, didRetrieve id: Data) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func postViewModel(_ viewModel: PostViewModel, didUpdate id: Data, subscribed: Bool) {
        NotificationCenter.default.post(
            name: subscribed
                ? FPPost.wasSubscribedToNotification
                : FPPost.wasUnsubscribedFromNotification,
            object: self,
            userInfo: ["item": vm.post.value.makePreview()]
        )
    }

    func postViewModel(_ viewModel: PostViewModel, didReport id: Data) {
        presentBasicAlert(text: "Post.Report.Success")
    }

    func postViewModel(_ viewModel: PostViewModel, didDelete id: Data) {
        NotificationCenter.default.post(
            name: FPPost.wasDeletedNotification,
            object: self,
            userInfo: ["item": vm.post.value.makePreview()]
        )

        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func postViewModel(_ viewModel: PostViewModel, didReportCommentAtPosition position: Int, inside id: Data, onCompletion handler: @escaping () -> Void) {
        presentBasicAlert(text: "Post.Comment.Report.Success")
        handler()
    }

    func postViewModel(_ viewModel: PostViewModel, didDeleteCommentAtPosition position: Int, inside id: Data, onCompletion handler: @escaping () -> Void) {
        guard let comment = vm.makeDeletedComment(fromPosition: position) else { return handler() }
        NotificationCenter.default.post(
            name: FPComment.wasDeletedNotification,
            object: self,
            userInfo: ["item": comment, "postId": vm.post.value.id, "_completionHandler": handler]
        )
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        guard !errored else { return nil }
        errored = true

        switch GRPCStatus.Code(rawValue: code)! {
        case .notFound:
            NotificationCenter.default.post(name: FPPost.wasNotFoundNotification, object: self)
            return "Post.Error.NotFound"

        case .invalidArgument:
            switch message {
            case "invalid_uuid":
                NotificationCenter.default.post(name: FPPost.wasNotFoundNotification, object: self)
                return "Post.Error.NotFound"

            default:
                return "Error"
            }

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
