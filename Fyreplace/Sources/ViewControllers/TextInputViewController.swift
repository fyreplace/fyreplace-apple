import ReactiveSwift
import UIKit

class TextInputViewController: UIViewController {
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var loader: UIActivityIndicatorView!
    @IBOutlet
    var length: UILabel!
    @IBOutlet
    var content: UITextView!

    var textInputViewModel: TextInputViewModel! { nil }
    var maxContentLength: Int { 0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        let maxLength = maxContentLength
        done.reactive.isEnabled <~ textInputViewModel.isLoading.negate()
        loader.reactive.isAnimating <~ textInputViewModel.isLoading
        length.reactive.text <~ textInputViewModel.text.map {
            String.localizedStringWithFormat(.tr("Bio.Length"), $0.count, maxLength)
        }
        length.reactive.textColor <~ textInputViewModel.text
            .map { $0.count <= maxLength }
            .skipRepeats()
            .map { $0 ? .labelCompat : .systemRed }
        content.becomeFirstResponder()
    }

    @IBAction
    func onCancelPressed() {
        dismiss(animated: true)
    }

    @IBAction
    func onDonePressed() {
        dismiss(animated: true)
    }
}
