import GRPC
import ReactiveSwift
import UIKit

class BioViewController: TextInputViewController {
    override var textInputViewModel: TextInputViewModel! { vm }
    override var maxContentLength: Int { 3000 }

    @IBOutlet
    var vm: BioViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        content.text = vm.bio.value
        vm.bio <~ content.reactive.continuousTextValues
    }

    override func onDonePressed() {
        vm.updateBio()
    }
}

extension BioViewController: BioViewModelDelegate {
    func onUpdateBio() {
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }

    func errorKey(for code: Int, with message: String?) -> String? {
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
