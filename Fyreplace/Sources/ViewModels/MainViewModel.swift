import Foundation
import ReactiveSwift
import SwiftProtobuf

class MainViewModel: ViewModel {
    @IBOutlet
    weak var delegate: MainViewModelDelegate?

    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidConnectNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentShouldBeReloadedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.wasBlockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.wasUnblockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }
    }

    func confirmActivation(with token: String) {
        let request = FPConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmActivation(request).response
        response.whenSuccess { self.onConfirmActivation(token: $0.token) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0, canAutoDisconnect: false) }
    }

    func confirmConnection(with token: String) {
        let request = FPConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmConnection(request).response
        response.whenSuccess { self.onConfirmConnection(token: $0.token) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0, canAutoDisconnect: false) }
    }

    func confirmEmailUpdate(with token: String) {
        let request = FPToken.with { $0.token = token }
        let response = userService.confirmEmailUpdate(request).response
        response.whenSuccess { _ in self.onConfirmEmailUpdate(token: token) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0, canAutoDisconnect: false) }
    }

    func retrieveMe() {
        let request = Google_Protobuf_Empty()
        let response = userService.retrieveMe(request).response
        response.whenSuccess { self.setCurrentUser($0) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func acknowledgeComment(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = commentService.acknowledge(request).response
        response.whenSuccess { _ in self.delegate?.mainViewModel(self, didAcknowledgeComment: id) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func registerToken(token: String) {
        let request = FPMessagingToken.with {
            $0.service = .apns
            $0.token = token
        }
        let response = notificationService.registerToken(request).response
        response.whenSuccess { _ in self.delegate?.mainViewModel(self, didRegisterToken: token) }
    }

    func tryRetrieveMe() {
        guard authToken.get() != nil else { return }
        retrieveMe()
    }

    private func onConfirmActivation(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate?.mainViewModel(self, didConfirmActivationWithToken: token)
        } else {
            delegate?.viewModel(self, didFailWithError: KeychainError.set)
        }
    }

    private func onConfirmConnection(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate?.mainViewModel(self, didConfirmConnectionWithToken: token)
        } else {
            delegate?.viewModel(self, didFailWithError: KeychainError.set)
        }
    }

    private func onConfirmEmailUpdate(token: String) {
        retrieveMe()
        delegate?.mainViewModel(self, didConfirmEmailUpdateWithToken: token)
    }
}

@objc
protocol MainViewModelDelegate: ViewModelDelegate {
    func mainViewModel(_ viewModel: MainViewModel, didConfirmActivationWithToken token: String)

    func mainViewModel(_ viewModel: MainViewModel, didConfirmConnectionWithToken token: String)

    func mainViewModel(_ viewModel: MainViewModel, didConfirmEmailUpdateWithToken token: String)

    func mainViewModel(_ viewModel: MainViewModel, didAcknowledgeComment id: Data)

    func mainViewModel(_ viewModel: MainViewModel, didRegisterToken token: String)
}
