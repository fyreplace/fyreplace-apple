import Foundation
import ReactiveSwift

class UserViewModel: ViewModel {
    @IBOutlet
    weak var delegate: UserViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)

    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)

    func retrieve(id: String) {
        let request = FPStringId.with { $0.id = id }
        let response = userService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess { self.user.value = $0 }
        response.whenFailure(delegate.onError(_:))
    }

    func report() {
        let request = FPStringId.with { $0.id = user.value!.profile.id }
        let response = userService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure(delegate.onError(_:))
    }
}

@objc
protocol UserViewModelDelegate: ViewModelDelegate {
    func onReport()
}
