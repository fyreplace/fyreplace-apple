import Foundation
import ReactiveSwift
import SwiftProtobuf

class MainViewModel: ViewModel {
    @IBOutlet
    weak var delegate: MainViewModelDelegate!

    private lazy var accountService = FPAccountServiceNIOClient(channel: Self.rpc.channel)
    private lazy var userService = FPUserServiceNIOClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userConnectedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.shouldReloadUserNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: BlockedUsersViewController.userBlockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        NotificationCenter.default.reactive
            .notifications(forName: BlockedUsersViewController.userUnblockedNotification)
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
        response.whenSuccess { self.onConfirmConnection(token: $0.token, activated: true) }
        response.whenFailure(delegate.onError(_:))
    }

    func confirmConnection(with token: String) {
        let request = FPConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmConnection(request).response
        response.whenSuccess { self.onConfirmConnection(token: $0.token, activated: false) }
        response.whenFailure(delegate.onError(_:))
    }

    func confirmEmailUpdate(with token: String) {
        let request = FPToken.with { $0.token = token }
        let response = userService.confirmEmailUpdate(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onConfirmEmailUpdate() }
        response.whenFailure(delegate.onError(_:))
    }

    func retrieveMe() {
        let response = userService.retrieveMe(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { self.setCurrentUser($0) }
        response.whenFailure(delegate.onError(_:))
    }

    private func onConfirmConnection(token: String, activated: Bool) {
        if authToken.set(token.data(using: .utf8)!) {
            NotificationCenter.default.post(name: FPUser.userConnectedNotification, object: self)
            if activated {
                delegate.onConfirmActivation()
            }
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

    func onConfirmEmailUpdate()
}
