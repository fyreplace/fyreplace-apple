import Foundation

class BlockedUsersViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BlockedUsersViewModelDelegate!

    private lazy var blockedUserLister = ItemLister<FPProfile, FPProfiles, FPUserServiceNIOClient>(
        delegatingTo: delegate,
        using: userService,
        forward: true
    )

    func blockedUser(at position: Int) -> FPProfile {
        return blockedUserLister.items[position]
    }

    func updateBlock(userId: Data, blocked: Bool, at position: Int) {
        let request = FPBlock.with {
            $0.id = userId
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.blockedUsersViewModel(self, didUpdateAtPosition: position, blocked: blocked) }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
    }
}

extension BlockedUsersViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { blockedUserLister }

    func itemListView(_ listViewController: ItemListViewController, itemPreviewTypeAtPosition position: Int) -> String {
        return "BlockedUser"
    }
}

@objc
protocol BlockedUsersViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func blockedUsersViewModel(_ viewModel: BlockedUsersViewModel, didUpdateAtPosition position: Int, blocked: Bool)
}
