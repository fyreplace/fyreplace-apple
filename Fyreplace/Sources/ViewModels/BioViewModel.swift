import Foundation
import ReactiveSwift

class BioViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: BioViewModelDelegate?

    var text: MutableProperty<String> { bio }
    let isLoading = MutableProperty(false)
    let bio = MutableProperty("")

    override func awakeFromNib() {
        super.awakeFromNib()
        bio.value = currentUser?.bio ?? ""
    }

    func updateBio() {
        isLoading.value = true
        let request = FPBio.with { $0.bio = bio.value }
        let response = userService.updateBio(request).response
        response.whenSuccess { _ in self.delegate?.bioViewModel(self, didUpdateBio: self.bio.value) }
        response.whenFailure { self.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading.value = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol BioViewModelDelegate: ViewModelDelegate {
    func bioViewModel(_ viewModel: BioViewModel, didUpdateBio bio: String)
}
