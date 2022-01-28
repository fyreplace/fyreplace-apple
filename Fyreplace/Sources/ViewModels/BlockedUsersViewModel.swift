import Foundation

class BlockedUsersViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BlockedUsersViewModelDelegate!

    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)
    private lazy var blockedUserLister = ItemLister<FPProfile, FPProfiles, FPUserServiceClient>(
        delegatingTo: delegate,
        using: userService,
        forward: true
    )

    func blockedUser(at index: Int) -> FPProfile {
        return blockedUserLister.items[index]
    }

    func unblock(userId: String, at index: Int) {
        let request = FPBlock.with {
            $0.id = userId
            $0.blocked = false
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onUnblock(at: index) }
        response.whenFailure(delegate.onError(_:))
    }
}

extension BlockedUsersViewModel: ListViewDelegate {
    var lister: ItemListerProtocol { blockedUserLister }

    func itemPreviewType(atIndex index: Int) -> String {
        return "Default"
    }
}

@objc
protocol BlockedUsersViewModelDelegate: ViewModelDelegate, ItemListerDelegate {
    func onUnblock(at index: Int)
}
