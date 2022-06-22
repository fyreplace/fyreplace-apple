import Foundation

class BlockedUsersViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BlockedUsersViewModelDelegate!

    private lazy var userService = FPUserServiceNIOClient(channel: Self.rpc.channel)
    private lazy var blockedUserLister = ItemLister<FPProfile, FPProfiles, FPUserServiceNIOClient>(
        delegatingTo: delegate,
        using: userService,
        forward: true
    )

    func blockedUser(at index: Int) -> FPProfile {
        return blockedUserLister.items[index]
    }

    func updateBlock(userId: Data, blocked: Bool, at index: Int) {
        let request = FPBlock.with {
            $0.id = userId
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onUpdateBlock(blocked, at: index) }
        response.whenFailure { self.delegate.onError($0) }
    }
}

extension BlockedUsersViewModel: ItemListViewDelegate {
    var lister: ItemListerProtocol { blockedUserLister }

    func itemPreviewType(atIndex index: Int) -> String {
        return "Default"
    }
}

@objc
protocol BlockedUsersViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func onUpdateBlock(_ blocked: Bool, at index: Int)
}
