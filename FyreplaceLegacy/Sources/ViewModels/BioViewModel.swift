import Combine
import Foundation

class BioViewModel: ViewModel, TextInputViewModel {
    @IBOutlet
    weak var delegate: BioViewModelDelegate?

    var textPublisher: AnyPublisher<String, Never> { $bio.eraseToAnyPublisher() }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { $isLoading.eraseToAnyPublisher() }

    @Published
    var bio = ""

    @Published
    private(set) var isLoading = false

    override func awakeFromNib() {
        super.awakeFromNib()
        bio = currentUser?.bio ?? ""
    }

    func updateBio() {
        isLoading = true
        let request = FPBio.with { $0.bio = bio }
        let response = userService.updateBio(request).response
        response.whenSuccess { _ in self.delegate?.bioViewModel(self, didUpdateBio: self.bio) }
        response.whenFailure { self.onError($0) }
    }

    private func onError(_ error: Error) {
        isLoading = false
        delegate?.viewModel(self, didFailWithError: error)
    }
}

@objc
protocol BioViewModelDelegate: ViewModelDelegate {
    func bioViewModel(_ viewModel: BioViewModel, didUpdateBio bio: String)
}
