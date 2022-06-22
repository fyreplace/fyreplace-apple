import Foundation
import ReactiveSwift

class LoginViewModel: ViewModel {
    @IBOutlet
    weak var delegate: LoginViewModelDelegate!

    let isRegistering = MutableProperty(true)
    let email = MutableProperty("")
    let username = MutableProperty("")
    lazy var isEmailValid = email.map { $0.count.between(3, 100) }
    lazy var isUsernameValid = username.map { $0.count.between(3, 50) }
    lazy var canProceed = isRegistering.negate().or(isUsernameValid).and(isEmailValid)
    let isLoading = MutableProperty(false)

    private lazy var accountService = FPAccountServiceNIOClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    func register() {
        isLoading.value = true
        let request = FPUserCreation.with {
            $0.email = email.value
            $0.username = username.value
        }
        let response = accountService.create(request).response
        response.whenSuccess { _ in self.delegate.onRegister() }
        response.whenFailure { self.delegate.onError($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    func login() {
        isLoading.value = true
        let request = FPEmail.with { $0.email = email.value }
        let response = accountService.sendConnectionEmail(request).response
        response.whenSuccess { _ in self.delegate.onLogin(withPassword: false) }
        response.whenFailure { self.delegate.onError($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    func login(with password: String) {
        isLoading.value = true
        let request = FPConnectionCredentials.with {
            $0.email = email.value
            $0.password = password
            $0.client = .default
        }
        let response = accountService.connect(request).response
        response.whenSuccess { self.onLogin(token: $0.token) }
        response.whenFailure { self.delegate.onError($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    private func onLogin(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            NotificationCenter.default.post(name: FPUser.userConnectedNotification, object: self)
        } else {
            delegate.onError(KeychainError.set)
        }

        delegate.onLogin(withPassword: true)
    }
}

@objc
protocol LoginViewModelDelegate: ViewModelDelegate {
    func onRegister()

    func onLogin(withPassword: Bool)
}

private extension Int {
    func between(_ a: Int, _ b: Int) -> Bool {
        return self >= a && self <= b
    }
}
