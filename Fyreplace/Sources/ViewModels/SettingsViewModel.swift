import Foundation
import ReactiveSwift
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)

    private lazy var accountService = FPAccountServiceClient(channel: Self.rpc.channel)
    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
        user.value = getUser()
        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userChangedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in user.value = getUser() }
    }

    func updateAvatar(image: Data?) {
        let stream = userService.updateAvatar(callOptions: .authenticated)
        stream.response.whenSuccess { _ in self.onUpdateAvatar() }
        stream.response.whenFailure(delegate.onError(_:))
        stream.upload(image: image)
    }

    func updatePassword(password: String) {
        let request = FPPassword.with { $0.password = password }
        let response = userService.updatePassword(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onUpdatePassword() }
        response.whenFailure(delegate.onError(_:))
    }

    func sendEmailUpdateEmail(address: String) {
        let request = FPEmail.with { $0.email = address }
        let response = userService.sendEmailUpdateEmail(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onSendEmailUpdateEmail() }
        response.whenFailure(delegate.onError(_:))
    }

    func logout() {
        let response = accountService.disconnect(FPStringId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let response = accountService.delete(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure(delegate.onError(_:))
    }

    private func onUpdateAvatar() {
        delegate.onUpdateAvatar()
        NotificationCenter.default.post(name: FPUser.shouldReloadUserNotification, object: self)
    }

    private func onLogout() {
        if authToken.delete() {
            setUser(nil)
            delegate.onLogout()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }

    private func onDelete() {
        if authToken.delete() {
            setUser(nil)
            delegate.onDelete()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate {
    func onUpdateAvatar()

    func onUpdatePassword()

    func onSendEmailUpdateEmail()

    func onLogout()

    func onDelete()
}
