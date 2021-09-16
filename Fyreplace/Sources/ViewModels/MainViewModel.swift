import Foundation
import SwiftProtobuf
import ReactiveSwift

class MainViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: MainViewModelDelegate!

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private lazy var userService = FPBUserServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
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
        response.whenFailure(delegate.onError(_:))
    }

    func retrieveMe() {
        let response = userService.retrieveMe(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { self.setUser($0) }
        response.whenFailure(delegate.onError(_:))
    }

    private func onConfirmActivation(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            NotificationCenter.default.post(name: FPBUser.userConnectedNotification, object: self)
            delegate.onConfirmActivation()
        } else {
            delegate.onError(KeychainError.set)
        }
    }
}

@objc
protocol MainViewModelDelegate: ViewModelDelegate {
    func onConfirmActivation()
}
