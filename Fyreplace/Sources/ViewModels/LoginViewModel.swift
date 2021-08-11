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

    private lazy var accountClient = FPBAccountServiceClient(channel: LoginViewModel.rpc.channel)

    func register() {
        let userCreation = FPBUserCreation.with {
            $0.email = email.value
            $0.username = username.value
            $0.password = password.value
        }

        isLoading.value = true
        let response = accountClient.create(userCreation).response
        response.whenSuccess { _ in self.delegate.onRegisterSuccess() }
        response.whenFailure { self.delegate.onFailure($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }

    func login() {
        let credentials = FPBCredentials.with {
            $0.identifier = username.value
            $0.password = password.value
            $0.client = .with {
                $0.hardware = "mobile"
                $0.software = "darwin"
            }
        }

        isLoading.value = true
        let response = accountClient.connect(credentials).response
        response.whenSuccess { _ in self.delegate.onLoginSuccess() }
        response.whenFailure { self.delegate.onFailure($0) }
        response.whenComplete { _ in self.isLoading.value = false }
    }
}

@objc
protocol LoginViewModelDelegate: ViewModelDelegate {
    func onRegisterSuccess()

    func onLoginSuccess()
}

private extension Int {
    func between(_ a: Int, _ b: Int) -> Bool {
        return self >= a && self <= b
    }
}
