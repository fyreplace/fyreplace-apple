import Foundation
import ReactiveSwift
import SwiftProtobuf

class BioViewModel: ViewModel {
    @IBOutlet
    private weak var delegate: BioViewModelDelegate!

    let isLoading = MutableProperty(false)
    let bio = MutableProperty("")

    private lazy var userService = FPBUserServiceClient(channel: Self.rpc.channel)

    override func awakeFromNib() {
        super.awakeFromNib()
        bio.value = getUser()?.bio ?? ""
    }

    func updateBio() {
        isLoading.value = true
        let request = FPBBio.with { $0.bio = bio.value }
        let response = userService.updateBio(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.onUpdateBio() }
        response.whenFailure(onError(_:))
    }

    private func onUpdateBio() {
        delegate.onUpdateBio()
        NotificationCenter.default.post(name: FPBUser.shouldReloadUserNotification, object: self)
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate.onError(error)
    }
}

@objc
protocol BioViewModelDelegate: ViewModelDelegate where Self: UIViewController {
    func onUpdateBio()
}
