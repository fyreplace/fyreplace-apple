import Foundation
import ReactiveSwift

class UserViewModel: ViewModel {
    @IBOutlet
    weak var delegate: UserViewModelDelegate?

    let user = MutableProperty<FPUser?>(nil)
    let blocked = MutableProperty<Bool>(false)
    let banned = MutableProperty<Bool>(false)

    func retrieve(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = userService.retrieve(request).response
        response.whenSuccess(onRetrieve(_:))
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func updateBlock(blocked: Bool) {
        let id = user.value!.profile.id
        let request = FPBlock.with {
            $0.id = id
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request).response
        response.whenSuccess { _ in self.onBlockUpdate(id: id, blocked: blocked) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func report() {
        let id = user.value!.profile.id
        let request = FPId.with { $0.id = id }
        let response = userService.report(request).response
        response.whenSuccess { _ in self.delegate?.userViewModel(self, didReport: id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func ban(for sentence: BanSentence) {
        let id = user.value!.profile.id
        let request = FPBanSentence.with {
            $0.id = id

            switch sentence {
            case .week: $0.days = 7
            case .month: $0.days = 30
            case .ever: break
            }
        }
        let response = userService.ban(request).response
        response.whenSuccess { _ in self.onBan(id: id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    private func onRetrieve(_ user: FPUser) {
        self.user.value = user
        blocked.value = user.profile.isBlocked
        banned.value = user.profile.isBanned
    }

    private func onBlockUpdate(id: Data, blocked: Bool) {
        self.blocked.value = blocked
        delegate?.userViewModel(self, didUpdate: id, blocked: blocked)
    }

    private func onBan(id: Data) {
        banned.value = true
        delegate?.userViewModel(self, didBan: id)
    }
}

@objc
protocol UserViewModelDelegate: ViewModelDelegate {
    func userViewModel(_ viewModel: UserViewModel, didUpdate id: Data, blocked: Bool)

    func userViewModel(_ viewModel: UserViewModel, didReport id: Data)

    func userViewModel(_ viewModel: UserViewModel, didBan id: Data)
}

enum BanSentence {
    case week
    case month
    case ever
}
