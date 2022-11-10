import Foundation
import ReactiveSwift
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: SettingsViewModelDelegate!

    let user = MutableProperty<FPUser?>(nil)
    let blockedUsers = MutableProperty<UInt32>(0)

    private let authToken = Keychain.authToken

    override func awakeFromNib() {
        super.awakeFromNib()
        reloadUser()

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.currentDidChangeNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in reloadUser() }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.wasBlockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value += 1 }

        NotificationCenter.default.reactive
            .notifications(forName: FPUser.wasUnblockedNotification)
            .take(during: reactive.lifetime)
            .observe(on: UIScheduler())
            .observeValues { [unowned self] _ in blockedUsers.value -= 1 }
    }

    func updateAvatar(image: Data?) {
        let stream = userService.updateAvatar(callOptions: .authenticated)
        stream.response.whenSuccess { self.onUpdateAvatar($0) }
        stream.response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
        stream.upload(image)
    }

    func sendEmailUpdateEmail(email: String) {
        let request = FPEmail.with { $0.email = email }
        let response = userService.sendEmailUpdateEmail(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.settingsViewModel(self, didSendEmailUpdateEmail: email) }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
    }

    func logout() {
        let response = accountService.disconnect(FPId(), callOptions: .authenticated).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
    }

    func delete() {
        let request = Google_Protobuf_Empty()
        let response = accountService.delete(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure { self.delegate.viewModel(self, didFailWithError: $0) }
    }

    private func reloadUser() {
        user.value = currentUser
        blockedUsers.value = user.value?.blockedUsers ?? 0
    }

    private func onUpdateAvatar(_ image: FPImage) {
        delegate.settingsViewModel(self, didUpdateAvatar: image.url)
        user.modify { $0?.profile.avatar = image }
    }

    private func onLogout() {
        if authToken.delete() {
            setCurrentUser(nil)
            delegate.settingsViewModelDidLogout(self)
        } else {
            delegate.viewModel(self, didFailWithError: KeychainError.delete)
        }
    }

    private func onDelete() {
        if authToken.delete() {
            setCurrentUser(nil)
            delegate.settingsViewModelDidDelete(self)
        } else {
            delegate.viewModel(self, didFailWithError: KeychainError.delete)
        }
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate {
    func settingsViewModel(_ viewModel: SettingsViewModel, didUpdateAvatar url: String)

    func settingsViewModel(_ viewModel: SettingsViewModel, didSendEmailUpdateEmail email: String)

    func settingsViewModelDidLogout(_ viewModel: SettingsViewModel)

    func settingsViewModelDidDelete(_ viewModel: SettingsViewModel)
}
