import Foundation
import ReactiveSwift

class BioViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: BioViewModelDelegate!

    var text: MutableProperty<String> { bio }
    let isLoading = MutableProperty(false)
    let bio = MutableProperty("")

    private lazy var userService = FPUserServiceNIOClient(channel: Self.rpc.channel)

    override func awakeFromNib() {
        super.awakeFromNib()
        bio.value = currentUser?.bio ?? ""
    }

    func updateBio() {
        isLoading.value = true
        let request = FPBio.with { $0.bio = bio.value }
        let response = userService.updateBio(request, callOptions: .authenticated).response
        response.whenSuccess { _ in self.delegate.onUpdateBio() }
        response.whenFailure { self.delegate.onError($0) }
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
