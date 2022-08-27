import ReactiveCocoa
import ReactiveSwift
import UIKit

class BaseListViewController: DynamicTableViewController {
    weak var listViewDelegate: BaseListViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listViewDelegate.lister.startListing()
    }

    override func viewWillDisappear(_ animated: Bool) {
        listViewDelegate.lister.stopListing()
        super.viewWillDisappear(animated)
    }

    private func onApplicationWillEnterForeground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        listViewDelegate.lister.startListing()
    }

    private func onApplicationDidEnterBackground(_ notification: Notification) {
        guard viewIfLoaded?.window != nil else { return }
        listViewDelegate.lister.stopListing()
    }
}

@objc
protocol BaseListViewDelegate: NSObjectProtocol {
    var lister: BaseListerProtocol! { get }
}
