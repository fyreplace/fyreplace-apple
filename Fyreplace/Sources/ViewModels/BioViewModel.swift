import Foundation
import ReactiveSwift
import SwiftProtobuf

class BioViewModel: ViewModel {
    @IBOutlet
    weak var delegate: BioViewModelDelegate!

    let isLoading = MutableProperty(false)
    let bio = MutableProperty("")

    private lazy var userService = FPUserServiceClient(channel: Self.rpc.channel)

    override func awakeFromNib() {
        super.awakeFromNib()
        bio.value = getCurrentUser()?.bio ?? ""
    }

    func updateBio() {
        isLoading.value = true
        let request = FPBio.with { $0.bio = bio.value }
        let response = userService.updateBio(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onUpdateBio() }
        response.whenFailure(onError(_:))
    }

    private func onUpdateBio() {
        delegate.onUpdateBio()
        NotificationCenter.default.post(name: FPUser.shouldReloadUserNotification, object: self)
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.onError(error)
    }
}

@objc
protocol BioViewModelDelegate: ViewModelDelegate {
    func onUpdateBio()
}
