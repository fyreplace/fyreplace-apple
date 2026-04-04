import Combine
import GRPC
import UIKit

class BioViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel { vm }
    override var maxContentLength: Int { 3000 }

    @IBOutlet
    var vm: BioViewModel!

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = vm.bio

        content.textPublisher
            .compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .assign(to: &vm.$bio)
    }

    override func onDonePressed() {
        vm.updateBio()
    }
}

extension BioViewController: BioViewModelDelegate {
    func bioViewModel(_ viewModel: BioViewModel, didUpdateBio bio: String) {
        NotificationCenter.default.post(name: FPUser.currentShouldBeReloadedNotification, object: self)
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }

    func viewModel(_ viewModel: ViewModel, errorKeyForCode code: Int, withMessage message: String?) -> String? {
        switch GRPCStatus.Code(rawValue: code)! {
        case .invalidArgument:
            return content.text.count > maxContentLength
                ? "Bio.Error.TooLong"
                : "Error.Validation"

        default:
            return "Error"
        }
    }
}
