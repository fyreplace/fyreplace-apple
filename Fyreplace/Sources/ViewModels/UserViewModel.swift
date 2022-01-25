import Foundation
import ReactiveSwift

class UserViewModel: ViewModel {
    @IBOutlet
    weak var delegate: UserViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)
    let blocked = MutableProperty<Bool>(false)

    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)

    func retrieve(id: String) {
        let request = FPStringId.with { $0.id = id }
        let response = userService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure(delegate.onError(_:))
    }

    func updateBlock(blocked: Bool) {
        let request = FPBlock.with {
            $0.id = user.value!.profile.id
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onBlockUpdate(blocked) }
        response.whenFailure(delegate.onError(_:))
    }

    func report() {
        let request = FPStringId.with { $0.id = user.value!.profile.id }
        let response = userService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure(delegate.onError(_:))
    }

    private func onRetrieve(_ user: FPUser) {
        self.user.value = user
        self.blocked.value = user.profile.isBlocked
    }

    private func onBlockUpdate(_ blocked: Bool) {
        self.blocked.value = blocked
        self.delegate.onBlockUpdate(blocked)
    }
}

@objc
protocol UserViewModelDelegate: ViewModelDelegate {
    func onBlockUpdate(_ blocked: Bool)

    func onReport()
}
