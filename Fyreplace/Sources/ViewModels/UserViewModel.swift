import Foundation
import ReactiveSwift

class UserViewModel: ViewModel {
    @IBOutlet
    weak var delegate: UserViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)
    let blocked = MutableProperty<Bool>(false)
    let banned = MutableProperty<Bool>(false)

    func retrieve(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = userService.retrieve(request, callOptions: .authenticated).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure { self.delegate.onError($0) }
    }

    func updateBlock(blocked: Bool) {
        let request = FPBlock.with {
            $0.id = user.value!.profile.id
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onBlockUpdate(blocked) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func report() {
        let request = FPId.with { $0.id = user.value!.profile.id }
        let response = userService.report(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onReport() }
        response.whenFailure { self.delegate.onError($0) }
    }

    func ban(for sentence: BanSentence) {
        let request = FPBanSentence.with {
            $0.id = user.value!.profile.id

            switch sentence {
            case .week: $0.days = 7
            case .month: $0.days = 30
            case .ever: break
            }
        }
        let response = userService.ban(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onBan() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onRetrieve(_ user: FPUser) {
        self.user.value = user
        blocked.value = user.profile.isBlocked
        banned.value = user.profile.isBanned
    }

    private func onBlockUpdate(_ blocked: Bool) {
        self.blocked.value = blocked
        delegate.onBlockUpdate(blocked)
    }

    private func onBan() {
        banned.value = true
        delegate.onBan()
    }
}

@objc
protocol UserViewModelDelegate: ViewModelDelegate {
    func onBlockUpdate(_ blocked: Bool)

    func onReport()

    func onBan()
}

enum BanSentence {
    case week
    case month
    case ever
}
