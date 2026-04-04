import Combine
import Foundation
import SwiftProtobuf

class SettingsViewModel: ViewModel {
    @IBOutlet
    weak var delegate: SettingsViewModelDelegate?

    @Published
    private(set) var user: FPUser?

    @Published
    private(set) var blockedUsers: UInt32 = 0

    private var cancellables = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()
        reloadUser()

        NotificationCenter.default
            .publisher(for: FPUser.currentDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in reloadUser() }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: FPUser.wasBlockedNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in blockedUsers += 1 }
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: FPUser.wasUnblockedNotification)
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in blockedUsers -= 1 }
            .store(in: &cancellables)
    }

    func updateAvatar(image: Data?) {
        let stream = userService.updateAvatar()
        stream.response.whenSuccess { self.onUpdateAvatar($0) }
        stream.response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
        stream.upload(image)
    }

    func sendEmailUpdateEmail(email: String) {
        let request = FPEmail.with { $0.email = email }
        let response = userService.sendEmailUpdateEmail(request).response
        response.whenSuccess { _ in self.delegate?.settingsViewModel(self, didSendEmailUpdateEmail: email) }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func logout() {
        let response = accountService.disconnect(FPId()).response
        response.whenSuccess { _ in self.onLogout() }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    func delete() {
        let request = Google_Protobuf_Empty()
        let response = accountService.delete(request).response
        response.whenSuccess { _ in self.onDelete() }
        response.whenFailure { self.delegate?.viewModel(self, didFailWithError: $0) }
    }

    private func reloadUser() {
        user = currentUser
        blockedUsers = user?.blockedUsers ?? 0
    }

    private func onUpdateAvatar(_ image: FPImage) {
        delegate?.settingsViewModel(self, didUpdateAvatar: image.url)
        user?.profile.avatar = image
    }

    private func onLogout() {
        _ = KeychainWrapper.authToken.delete()
        setCurrentUser(nil)
        delegate?.settingsViewModelDidLogout(self)
    }

    private func onDelete() {
        _ = KeychainWrapper.authToken.delete()
        setCurrentUser(nil)
        delegate?.settingsViewModelDidDelete(self)
    }
}

@objc
protocol SettingsViewModelDelegate: ViewModelDelegate {
    func settingsViewModel(_ viewModel: SettingsViewModel, didUpdateAvatar url: String)

    func settingsViewModel(_ viewModel: SettingsViewModel, didSendEmailUpdateEmail email: String)

    func settingsViewModelDidLogout(_ viewModel: SettingsViewModel)

    func settingsViewModelDidDelete(_ viewModel: SettingsViewModel)
}
