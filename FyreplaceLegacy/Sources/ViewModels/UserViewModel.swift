import Combine
import Foundation

class UserViewModel: ViewModel {
    @IBOutlet
    weak var delegate: UserViewModelDelegate?

    @Published
    private(set) var user: FPUser?

    @Published
    private(set) var blocked = false

    @Published
    private(set) var banned = false

    func retrieve(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = userService.retrieve(request).response
        response.whenSuccess(onRetrieve)
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func updateBlock(blocked: Bool) {
        let id = user!.profile.id
        let request = FPBlock.with {
            $0.id = id
            $0.blocked = blocked
        }
        let response = userService.updateBlock(request).response
        response.whenSuccess { _ in self.onBlockUpdate(id: id, blocked: blocked) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func report() {
        let id = user!.profile.id
        let request = FPId.with { $0.id = id }
        let response = userService.report(request).response
        response.whenSuccess { _ in self.delegate?.userViewModel(self, didReport: id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func ban(for sentence: BanSentence) {
        let id = user!.profile.id
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
        self.user = user
        blocked = user.profile.isBlocked
        banned = user.profile.isBanned
    }

    private func onBlockUpdate(id: Data, blocked: Bool) {
        self.blocked = blocked
        delegate?.userViewModel(self, didUpdate: id, blocked: blocked)
    }

    private func onBan(id: Data) {
        banned = true
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
