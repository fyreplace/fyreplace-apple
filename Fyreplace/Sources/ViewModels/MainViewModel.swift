import Foundation
import ReactiveSwift
import SwiftProtobuf

class MainViewModel: ViewModel {
    @IBOutlet
    weak var delegate: MainViewModelDelegate!

    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.connectionNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.shouldReloadCurrentUserNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.blockNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.unblockNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        if authToken.get() != nil {
            retrieveMe()
        }
    }

    func confirmActivation(with token: String) {
        let request = FPConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmActivation(request).response
        response.whenSuccess { self.onConfirmActivation(token: $0.token) }
        response.whenFailure { self.delegate.onError($0, canAutoDisconnect: false) }
    }

    func confirmConnection(with token: String) {
        let request = FPConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmConnection(request).response
        response.whenSuccess { self.onConfirmConnection(token: $0.token) }
        response.whenFailure { self.delegate.onError($0, canAutoDisconnect: false) }
    }

    func confirmEmailUpdate(with token: String) {
        let request = FPToken.with { $0.token = token }
        let response = userService.confirmEmailUpdate(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onConfirmEmailUpdate() }
        response.whenFailure { self.delegate.onError($0, canAutoDisconnect: false) }
    }

    func retrieveMe() {
        let request = Google_Protobuf_Empty()
        let response = userService.retrieveMe(request, callOptions: .authenticated).response
        response.whenSuccess { self.setCurrentUser($0) }
        response.whenFailure { self.delegate.onError($0) }
    }

    func acknowledgeComment(id: Data) {
        let request = FPId.with { $0.id = id }
        let response = commentService.acknowledge(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onAcknowledgeComment() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onConfirmActivation(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate.onConfirmActivation()
        } else {
            delegate.onError(KeychainError.set)
        }
    }

    private func onConfirmConnection(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate.onConfirmConnection()
        } else {
            delegate.onError(KeychainError.set)
        }
    }

    private func onConfirmEmailUpdate() {
        retrieveMe()
        delegate.onConfirmEmailUpdate()
    }
}

@objc
protocol MainViewModelDelegate: ViewModelDelegate {
    func onConfirmActivation()

    func onConfirmConnection()

    func onConfirmEmailUpdate()

    func onAcknowledgeComment()
}
