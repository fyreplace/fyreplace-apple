import ReactiveSwift
import UIKit

class TextInputViewController: UIViewController {
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var content: UITextView!

    var textInputViewModel: TextInputViewModel! { nil }
    var maxContentLength: Int { 0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        let maxLength = maxContentLength
        done.reactive.isEnabled <~ textInputViewModel.isLoading.negate()
        navigationItem.reactive.title <~ textInputViewModel.text.map {
            String.localizedStringWithFormat(
                .tr("TextInput.Length." + ($0.count <= maxLength ? "Ok" : "TooLong")), $0.count,
                maxLength
            )
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        content.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        content.resignFirstResponder()
        super.viewWillDisappear(animated)
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
