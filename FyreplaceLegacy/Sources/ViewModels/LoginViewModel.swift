import Combine
import Foundation

class LoginViewModel: ViewModel {
    @IBOutlet
    weak var delegate: LoginViewModelDelegate?

    @Published
    var isRegistering = true

    @Published
    var email = ""

    @Published
    var username = ""

    @Published
    var conditionsAccepted = false

    @Published
    var isLoading = false

    lazy var isEmailValidPublisher = $email.map { $0.count.between(3, 100) }

    lazy var isUsernameValidPublisher = $username.map { $0.count.between(3, 50) }

    lazy var canProceedPublisher = $isRegistering.combineLatest(isEmailValidPublisher, isUsernameValidPublisher, $conditionsAccepted) { isRegistering, isEmailValid, isUsernameValid, conditionsAccepted in
            isEmailValid && (!isRegistering || (isUsernameValid && conditionsAccepted))
    }

    private let authToken = KeychainWrapper.authToken

    func register() {
        isLoading = true
        let request = FPUserCreation.with {
            $0.email = email
            $0.username = username
        }
        let response = accountService.create(request).response
        response.whenSuccess { _ in self.delegate?.loginViewModel(self, didRegisterWithEmail: self.email, andUsername: self.username) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
        response.whenComplete { _ in self.isLoading = false }
    }

    func login() {
        isLoading = true
        let request = FPEmail.with { $0.email = email }
        let response = accountService.sendConnectionEmail(request).response
        response.whenSuccess { _ in self.delegate?.loginViewModel(self, didLoginWithPassword: false) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
        response.whenComplete { _ in self.isLoading = false }
    }

    func login(with password: String) {
        isLoading = true
        let request = FPConnectionCredentials.with {
            $0.email = email
            $0.password = password
            $0.client = .default
        }
        let response = accountService.connect(request).response
        response.whenSuccess { self.onPasswordLogin(token: $0.token) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
        response.whenComplete { _ in self.isLoading = false }
    }

    private func onPasswordLogin(token: String) {
        if authToken.set(token.data(using: .utf8)!) {
            delegate?.loginViewModel(self, didLoginWithPassword: true)
        } else {
            delegate?.viewModel(self, didFailWithError: KeychainError.set)
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
