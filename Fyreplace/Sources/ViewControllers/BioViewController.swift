import GRPC
import ReactiveSwift
import UIKit

class BioViewController: UIViewController {
    @IBOutlet
    var vm: BioViewModel!
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var loader: UIActivityIndicatorView!
    @IBOutlet
    var length: UILabel!
    @IBOutlet
    var bio: UITextView!

    private static let maxBioLength = 3000

    override func viewDidLoad() {
        super.viewDidLoad()
        done.reactive.isEnabled <~ vm.isLoading.negate()
        loader.reactive.isAnimating <~ vm.isLoading
        bio.text = vm.bio.value
        length.reactive.text <~ vm.bio.map {
            String.localizedStringWithFormat(.tr("Bio.Length"), $0.count, BioViewController.maxBioLength)
        }
        length.reactive.textColor <~ vm.bio
            .map { $0.count <= BioViewController.maxBioLength }
            .skipRepeats()
            .map { $0 ? .labelCompat : .systemRed }
        vm.bio <~ bio.reactive.continuousTextValues
        bio.becomeFirstResponder()
    }

    @IBAction
    func onCancelPressed() {
        dismiss(animated: true)
    }

    @IBAction
    func onDonePressed() {
        vm.updateBio()
    }
}

extension BioViewController: BioViewModelDelegate {
    func onUpdateBio() {
        DispatchQueue.main.async { self.dismiss(animated: true) }
    }

    func onFailure(_ error: Error) {
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

        let key: String

        switch status.code {
        case .invalidArgument:
            key = bio.text.count > BioViewController.maxBioLength
                ? "Bio.Error.TooLong"
                : "Error.Validation"

        default:
            key = "Error"
        }

        presentBasicAlert(text: key, feedback: .error)
    }
}
