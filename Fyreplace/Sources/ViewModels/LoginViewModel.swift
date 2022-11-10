import Foundation
import ReactiveSwift

class LoginViewModel: ViewModel {
    @IBOutlet
    weak var delegate: LoginViewModelDelegate!

    let isRegistering = MutableProperty(true)
    let email = MutableProperty("")
    let username = MutableProperty("")
    let conditionsAccepted = MutableProperty(false)
    lazy var isEmailValid = email.map { $0.count.between(3, 100) }
    lazy var isUsernameValid = username.map { $0.count.between(3, 50) }
    lazy var canProceed = isRegistering.negate()
        .or(isUsernameValid.and(conditionsAccepted))
        .and(isEmailValid)
    let isLoading = MutableProperty(false)

    private let authToken = Keychain.authToken

    func register() {
        isLoading.value = true
        let request = FPUserCreation.with {
            $0.email = email.value
            $0.username = username.value
        }
        let response = accountService.create(request).response
        response.whenSuccess { _ in self.delegate.loginViewModel(self, didRegisterWithEmail: self.email.value, andUsername: self.username.value) }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    func login() {
        isLoading.value = true
        let request = FPEmail.with { $0.email = email.value }
        let response = accountService.sendConnectionEmail(request).response
        response.whenSuccess { _ in self.delegate.loginViewModel(self, didLoginWithPassword: false) }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
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
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    private func onLogin(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate.loginViewModel(self, didLoginWithPassword: true)
        } else {
            delegate.viewModel(self, didFailWithError: KeychainError.set)
        }
    }
}

@objc
protocol LoginViewModelDelegate: ViewModelDelegate {
    func loginViewModel(_ viewModel: LoginViewModel, didRegisterWithEmail email: String, andUsername username: String)

    func loginViewModel(_ viewModel: LoginViewModel, didLoginWithPassword withPassword: Bool)
}

private extension Int {
    func between(_ a: Int, _ b: Int) -> Bool {
        return self >= a && self <= b
    }
}
