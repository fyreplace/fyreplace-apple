import UIKit

extension ViewModelDelegate where Self: UIViewController {
    func onFailure(_ error: Error) {
        presentBasicAlert(text: "Error", feedback: .error)
    }
}
