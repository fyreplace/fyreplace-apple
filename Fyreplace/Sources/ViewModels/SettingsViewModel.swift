import Foundation
import ReactiveSwift
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPBUser?>(nil)

    private lazy var accountService = FPBAccountServiceClient(channel: Self.rpc.channel)
    private lazy var userService = FPBUserServiceClient(channel: Self.rpc.channel)
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

    func sendEmailUpdateEmail(address: String) {
        let request = FPBEmail.with { $0.email = address }
        let response = userService.sendEmailUpdateEmail(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onSendEmailUpdateEmail() }
        response.whenFailure(delegate.onError(_:))
    }

    func logout() {
        let response = accountService.disconnect(FPBIntId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let response = accountService.delete(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure(delegate.onError(_:))
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

    private func onDelete() {
        if authToken.delete() {
            setUser(nil)
            NotificationCenter.default.post(name: FPBUser.userDisconnectedNotification, object: self)
            delegate.onDelete()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate where Self: UIViewController {
    func onSendEmailUpdateEmail()

    func onLogout()

    func onDelete()
}
