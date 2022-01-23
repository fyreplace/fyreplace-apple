import Foundation

class BlockedUsersViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BlockedUsersViewModelDelegate!

    private lazy var blockedUserLister = ItemLister<FPProfile, FPProfiles, FPUserServiceClient>(
        delegatingTo: delegate,
        using: FPUserServiceClient(channel: Self.rpc.channel),
        forward: true
    )

    func blockedUser(at index: Int) -> FPProfile {
        return blockedUserLister.items[index]
    }
}

extension BlockedUsersViewModel: ListViewDelegate {
    var lister: ItemListerProtocol { blockedUserLister }

    func itemPreviewType(atIndex index: Int) -> String {
        return "Default"
    }
}

@objc
protocol BlockedUsersViewModelDelegate: ViewModelDelegate, ItemListerDelegate {}
