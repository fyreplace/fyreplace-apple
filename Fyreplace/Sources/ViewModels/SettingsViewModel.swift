import Foundation
import ReactiveSwift

class SettingsViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPBUser?>(nil)

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
        user.value = getUser()
        NotificationCenter.default.reactive
            .notifications(forName: FPBUser.userChangedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in user.value = getUser() }
    }

    func logout() {
        let response = accountService.disconnect(FPBIntId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func onLogout() {
        if authToken.delete() {
            setUser(nil)
            NotificationCenter.default.post(name: FPBUser.userDisconnectedNotification, object: self)
            delegate.onLogout()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate {
    func onLogout()
}
