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

    func retrieveMe() {
        let response = userService.retrieveMe(Google_Protobuf_Empty(), callOptions: .authenticated).response
        response.whenSuccess { self.setUser($0) }
        response.whenFailure(onError(_:))
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
        retrieveMe()
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
