import Foundation

class MainViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: MainViewModelDelegate!

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    func confirmActivation(with token: String) {
        let request = FPBConnectionToken.with {
            $0.token = token
            $0.client = .default
        }
        let response = accountService.confirmActivation(request).response
        response.whenSuccess { self.onConfirmActivation(token: $0.token) }
        response.whenFailure { self.delegate.onFailure($0) }
    }

    private func onConfirmActivation(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate.onConfirmActivation()
        } else {
            delegate.onFailure(KeychainError.set)
        }
    }
}

@objc
protocol MainViewModelDelegate: ViewModelDelegate {
    func onConfirmActivation()
}
