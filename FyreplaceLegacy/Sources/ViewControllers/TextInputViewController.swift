import Combine
import UIKit

class TextInputViewController: UIViewController {
    @IBOutlet
    var done: UIBarButtonItem!
    @IBOutlet
    var content: UITextView!

    var textInputViewModel: TextInputViewModel! { nil }
    var maxContentLength: Int { 0 }

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        let maxLength = maxContentLength

        textInputViewModel.isLoadingPublisher
            .map { !$0 }
            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: done)
            .store(in: &cancellables)
        textInputViewModel.textPublisher
            .map {
                String.localizedStringWithFormat(
                    .tr("TextInput.Length." + ($0.count <= maxLength ? "Ok" : "TooLong")), $0.count,
                    maxLength
                )
            }
            .receive(on: RunLoop.main)
            .assign(to: \.title, on: navigationItem)
            .store(in: &cancellables)
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
