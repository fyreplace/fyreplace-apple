import UIKit
import ReactiveSwift
import GRPC
import SDWebImage

class PostViewController: UITableViewController {
    @IBOutlet
    var vm: PostViewModel!
    @IBOutlet
    var avatar: UIImageView!
    @IBOutlet
    var username: UILabel!
    @IBOutlet
    var dateCreated: UILabel!
    @IBOutlet
    var tableHeader: PostTableHeaderView!
    @IBOutlet
    var menu: Menu!
    @IBOutlet
    var subscribe: Action!
    @IBOutlet
    var unsubscribe: Action!
    @IBOutlet
    var report: Action!
    @IBOutlet
    var delete: Action!
    @IBOutlet
    var dateFormat: DateFormat!

    var userId: String?
    var itemPosition: Int!
    var post: FPPost!

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.retrieve(id: post.id)
        vm.post.producer.startWithValues(onPostChanged(_:))
        vm.subscribed.producer.startWithValues(onSubscriptionChanged(subscribed:))
    }

    @IBAction
    func onSharePressed() {
        let postUrl = URL(string: "https://fyreplace.link/posts/\(post.id)")
        let activityController = UIActivityViewController(activityItems: [postUrl as Any], applicationActivities: nil)
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
        presentChoiceAlert(text: "Post.Report") { _ in self.vm.report() }
    }

    @IBAction
    func onDeletePressed() {
        presentChoiceAlert(text: "Post.Delete") { _ in self.vm.delete() }
    }
    
    private func onPostChanged(_ post: FPPost?) {
        guard let post = post else { return }
        DispatchQueue.main.async { [self] in
            tableHeader.setup(with: post)
            tableView.reloadData()
            avatar.setAvatar(post.isAnonymous ? "" : post.author.avatar.url)
            username.setUsername(post.isAnonymous ? "" : post.author.username)
            dateCreated.text = dateFormat.string(from: post.dateCreated.date)
        }
    }
    
    private func onSubscriptionChanged(subscribed: Bool) {
        let userOwnsPost = vm.post.value?.hasAuthor ?? false && vm.post.value?.author.id == userId
        DispatchQueue.main.async { [self] in
            subscribe.isHidden = subscribed
            unsubscribe.isHidden = !subscribed
            report.isHidden = userOwnsPost
            delete.isHidden = !userOwnsPost
            menu.reload()
        }
    }
}

extension PostViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: comment count
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Comment", for: indexPath)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return .tr("Post.Comments.Title")
    }
}

extension PostViewController: PostViewModelDelegate {
    func onReport() {
        presentBasicAlert(text: "Post.Report.Success")
    }

    func onDelete() {
        NotificationCenter.default.post(name: ListViewController.itemDeletedNotification, object: self, userInfo: ["itemPosition": itemPosition as Any])
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

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

extension PostViewController: DynamicStackViewDelegate {
    func boundsDidUpdate(_ bounds: CGRect) {
        tableHeader.resize()
        tableView.tableHeaderView = tableHeader
    }
}
