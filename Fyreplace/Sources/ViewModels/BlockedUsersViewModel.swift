import Foundation

class BlockedUsersViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BlockedUsersViewModelDelegate?

    private lazy var blockedUserLister = ItemLister<FPProfile, FPProfiles, FPUserServiceNIOClient>(
        delegatingTo: delegate,
        using: userService,
        forward: true
    )

    func blockedUser(at position: Int) -> FPProfile {
        return blockedUserLister.items[position]
    }

    func unblock(userId: Data, at position: Int, onCompletion completion: @escaping (Bool) -> Void) {
        let request = FPBlock.with {
            $0.id = userId
            $0.blocked = false
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate?.blockedUsersViewModel(self, didUnblockAtPosition: position) { completion(true) } }
        response.whenFailure {
            self.delegate?.viewModel(self, didFailWithError: $0)
            completion(false)
        }
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
    func blockedUsersViewModel(_ viewModel: BlockedUsersViewModel, didUnblockAtPosition position: Int, onCompletion handler: @escaping () -> Void)
}
