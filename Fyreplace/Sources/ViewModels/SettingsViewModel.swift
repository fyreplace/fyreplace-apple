import Foundation
import ReactiveSwift
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)
    let blockedUsers = MutableProperty<UInt32>(0)

    private lazy var accountService = FPAccountServiceClient(channel: Self.rpc.channel)
    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
        reloadUser()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.userChangedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in reloadUser() }

        NotificationCenter.default.reactive
            .notifications(forName: BlockedUsersViewController.userBlockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value += 1 }

        NotificationCenter.default.reactive
            .notifications(forName: BlockedUsersViewController.userUnblockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value -= 1 }
    }

    func updateAvatar(image: Data?) {
        let stream = userService.updateAvatar(callOptions: .authenticated)
        stream.response.whenSuccess { self.onUpdateAvatar($0) }
        stream.response.whenFailure(delegate.onError(_:))
        stream.upload(image: image)
    }

    func sendEmailUpdateEmail(address: String) {
        let request = FPEmail.with { $0.email = address }
        let response = userService.sendEmailUpdateEmail(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onSendEmailUpdateEmail() }
        response.whenFailure(delegate.onError(_:))
    }

    func logout() {
        let response = accountService.disconnect(FPId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure(delegate.onError(_:))
    }

    func delete() {
        let response = accountService.delete(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure(delegate.onError(_:))
    }

    private func reloadUser() {
        let newUser = getCurrentUser()
        user.value = newUser
        blockedUsers.value = newUser?.blockedUsers ?? 0
    }

    private func onUpdateAvatar(_ image: FPImage) {
        delegate.onUpdateAvatar()
        user.modify { $0?.profile.avatar = image }
        NotificationCenter.default.post(name: FPUser.shouldReloadUserNotification, object: self)
    }

    private func onLogout() {
        if authToken.delete() {
            setCurrentUser(nil)
            delegate.onLogout()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }

    private func onDelete() {
        if authToken.delete() {
            setCurrentUser(nil)
            delegate.onDelete()
        } else {
            delegate.onError(KeychainError.delete)
        }
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate {
    func onUpdateAvatar()

    func onSendEmailUpdateEmail()

    func onLogout()

    func onDelete()
}
