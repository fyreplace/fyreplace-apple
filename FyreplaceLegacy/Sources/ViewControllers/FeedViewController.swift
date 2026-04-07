import Combine
import UIKit

class FeedViewController: UITableViewController {
    @IBOutlet
    var vm: FeedViewModel!
    @IBOutlet
    var emptyPlaceholder: UIView!
    @IBOutlet
    var help: UIBarButtonItem!

    private var postCount = 0
    private var isAuthenticated = false
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(.init(nibName: "TextPostFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "Text")
        tableView.register(.init(nibName: "ImagePostFeedTableViewCell", bundle: nil), forCellReuseIdentifier: "Image")

        isAuthenticated = currentUser != nil
        setupHelp()

        NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onApplicationWillEnterForeground($0) }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onApplicationDidEnterBackground($0) }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: FPUser.currentDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] in onCurrentUserDidChange($0) }
            .store(in: &cancellables)
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

    @IBAction
    func onRefreshValueChanged(_ sender: UIRefreshControl) {
        onRefresh()
    }

    private func onRefresh() {
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

    private func onCurrentUserDidChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let connected = info["connected"] as? Bool,
              connected != isAuthenticated
        else { return }

        isAuthenticated = connected
        setupHelp()
        onRefresh()
    }

    private func setupHelp() {
        navigationItem.setRightBarButton(isAuthenticated ? nil : help, animated: true)
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
            tableView.insertRows(at: .init(row: position, section: 0), with: .automatic)
            stopRefreshing()
        }
    }

    func feedViewModel(_ viewModel: FeedViewModel, didUpdatePostAtPosition position: Int) {
        DispatchQueue.main.async { [self] in
            tableView.reloadRows(at: .init(row: position, section: 0), with: .automatic)
            stopRefreshing()
        }
    }

    func feedViewModel(_ viewModel: FeedViewModel, didDismissPostAtPosition position: Int) {
        DispatchQueue.main.async { [self] in
            postCount -= 1
            tableView.deleteRows(at: .init(row: position, section: 0), with: .automatic)
        }
    }

    func didDismissAllPosts(_ viewModel: FeedViewModel) {
        DispatchQueue.main.async { [self] in
            postCount = 0
            tableView.reloadData()
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
