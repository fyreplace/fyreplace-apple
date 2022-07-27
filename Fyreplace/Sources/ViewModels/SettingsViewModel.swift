import Foundation
import ReactiveSwift
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)
    let blockedUsers = MutableProperty<UInt32>(0)

    private lazy var accountService = FPAccountServiceNIOClient(channel: Self.rpc.channel)
    private lazy var userService = FPUserServiceNIOClient(channel: Self.rpc.channel)
    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
        reloadUser()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentUserChangeNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in reloadUser() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.blockNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value += 1 }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.unblockNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value -= 1 }
    }

    func updateAvatar(image: Data?) {
        let stream = userService.updateAvatar(callOptions: .authenticated)
        stream.response.whenSuccess { self.onUpdateAvatar($0) }
        stream.response.whenFailure { self.delegate.onError($0) }
        stream.upload(image)
    }

    func sendEmailUpdateEmail(address: String) {
        let request = FPEmail.with { $0.email = address }
        let response = userService.sendEmailUpdateEmail(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onSendEmailUpdateEmail() }
        response.whenFailure { self.delegate.onError($0) }
    }

    func logout() {
        let response = accountService.disconnect(FPId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure { self.delegate.onError($0) }
    }

    func delete() {
        let response = accountService.delete(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure { self.delegate.onError($0) }
    }

    private func reloadUser() {
        user.value = currentUser
        blockedUsers.value = user.value?.blockedUsers ?? 0
    }

    private func onUpdateAvatar(_ image: FPImage) {
        delegate.onUpdateAvatar()
        user.modify { $0?.profile.avatar = image }
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
