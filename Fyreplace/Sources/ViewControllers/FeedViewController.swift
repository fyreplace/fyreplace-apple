import ReactiveCocoa
import ReactiveSwift
import UIKit

class FeedViewController: UITableViewController {
    @IBOutlet
    var vm: FeedViewModel!
    @IBOutlet
    var emptyPlaceholder: UIView!
    @IBOutlet
    var help: UIBarButtonItem!

    private var postCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "TextPostFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "Text")
        tableView.register(.init(nibName: "ImagePostFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "Image")

        refreshControl?.reactive.controlEvents(.valueChanged)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in onRefresh() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidChangeNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in onRefresh() }

        NotificationCenter.default.reactive
            .notifications(forName: UIApplication.willEnterForegroundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onApplicationWillEnterForeground($0) }

        NotificationCenter.default.reactive
            .notifications(forName: UIApplication.didEnterBackgroundNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in onApplicationDidEnterBackground($0) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.startListing()
    }

    override func viewDidDisappear(_ animated: Bool) {
        vm.stopListing()
        super.viewDidDisappear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let postController = segue.destination as? PostViewController,
           let cell = sender as? UITableViewCell,
           let position = tableView.indexPath(for: cell)?.row
        {
            postController.post = vm.post(at: position)
        }
    }

    @IBAction
    func onHelpPressed() {
        presentBasicAlert(text: "Feed.Help")
    }

    private func onRefresh() {
        navigationItem.setRightBarButton(currentUser == nil ? help : nil, animated: true)
        let count = postCount
        postCount = 0
        tableView.deleteRows(at: .init(rows: 0 ..< count, section: 0), with: .none)
        vm.refresh()
    }

    private func onApplicationWillEnterForeground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        vm.startListing()
    }

    private func onApplicationDidEnterBackground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        vm.stopListing()
    }
}

extension FeedViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = postCount == 0 ? emptyPlaceholder : nil
        return postCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = vm.post(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(
            withIdentifier: post?.chapters.first?.text.isEmpty ?? false ? "Image" : "Text",
            for: indexPath
        )

        guard let cell = cell as? FeedTableViewCell, let post else { return cell }
        cell.delegate = self
        cell.setup(withPost: post)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Post", sender: tableView.cellForRow(at: indexPath))
    }
}

extension FeedViewController: FeedViewModelDelegate {
    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        return "Error"
    }

    func feedViewModel(_ viewModel: FeedViewModel, didReceivePostAtPosition position: Int) {
        DispatchQueue.main.async { [self] in
            postCount += 1
            tableView.insertRows(at: [.init(row: position, section: 0)], with: .automatic)
            stopRefreshing()
        }
    }

    func feedViewModel(_ viewModel: FeedViewModel, didVotePostAtPosition position: Int) {
        DispatchQueue.main.async { [self] in
            postCount -= 1
            tableView.deleteRows(at: [.init(row: position, section: 0)], with: .automatic)
        }
    }

    func didFinishListing(_ viewModel: FeedViewModel) {
        DispatchQueue.main.async { self.stopRefreshing() }
    }

    private func stopRefreshing() {
        guard let refreshControl, refreshControl.isRefreshing else { return }
        refreshControl.endRefreshing()
    }
}

extension FeedViewController: FeedTableViewCellDelegate {
    func feedTableViewCell(_ cell: FeedTableViewCell, didSpread spread: Bool) {
        guard let position = tableView.indexPath(for: cell)?.row else { return }
        vm.vote(spread: spread, at: position)
    }
}
