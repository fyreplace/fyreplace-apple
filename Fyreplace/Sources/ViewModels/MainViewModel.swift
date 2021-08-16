import Foundation
import SwiftProtobuf
import ReactiveSwift

class MainViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: MainViewModelDelegate!

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private lazy var userService = FPBUserServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override init() {
        super.init()
        NotificationCenter.default.reactive
            .notifications(forName: FPBUser.userConnectedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in retrieveMe() }

        if authToken.get() != nil {
            retrieveMe()
        }
    }

    func confirmActivation(with token: String) {
        let request = FPBConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmActivation(request).response
        response.whenSuccess { self.onConfirmActivation(token: $0.token) }
        response.whenFailure { self.delegate.onFailure($0) }
    }

    func retrieveMe() {
        let response = userService.retrieveMe(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { self.onRetrieveMe(me: $0) }
        response.whenFailure { self.delegate.onFailure($0) }
    }

    private func onConfirmActivation(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            NotificationCenter.default.post(name: FPBUser.userConnectedNotification, object: self)
            delegate.onConfirmActivation()
        } else {
            delegate.onFailure(KeychainError.set)
        }
    }

    private func onRetrieveMe(me: FPBUser) {
        setUser(me)
    }
}

@objc
protocol MainViewModelDelegate: ViewModelDelegate {
    func onConfirmActivation()
}
