import Foundation
import ReactiveSwift

class LoginViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: LoginViewModelDelegate!

    let isRegistering = MutableProperty(true)
    let email = MutableProperty("")
    let username = MutableProperty("")
    let password = MutableProperty("")
    lazy var isEmailValid = email.map { $0.count.between(3, 100) }
    lazy var isUsernameValid = username.map { $0.count.between(3, 50) }
    lazy var isPasswordValid = password.map { $0.count.between(8, 100) }
    lazy var canProceed = isRegistering.negate().or(isEmailValid).and(isUsernameValid).and(isPasswordValid)
    let isLoading = MutableProperty(false)

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    func register() {
        let userCreation = FPBUserCreation.with {
            $0.email = email.value
            $0.username = username.value
            $0.password = password.value
        }

        isLoading.value = true
        let response = accountService.create(userCreation).response
        response.whenSuccess { _ in self.delegate.onRegister() }
        response.whenFailure { self.delegate.onError($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    func login() {
        let credentials = FPBCredentials.with {
            $0.identifier = username.value
            $0.password = password.value
            $0.client = .default
        }

        isLoading.value = true
        let response = accountService.connect(credentials).response
        response.whenSuccess { self.onLogin(token: $0.token) }
        response.whenFailure { self.delegate.onError($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    private func onLogin(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            NotificationCenter.default.post(name: FPBUser.userConnectedNotification, object: self)
            delegate.onLogin()
        } else {
            delegate.onError(KeychainError.set)
        }
    }
}

@objc
protocol LoginViewModelDelegate: ViewModelDelegate {
    func onRegister()

    func onLogin()
}

private extension Int {
    func between(_ a: Int, _ b: Int) -> Bool {
        return self >= a && self <= b
    }
}
