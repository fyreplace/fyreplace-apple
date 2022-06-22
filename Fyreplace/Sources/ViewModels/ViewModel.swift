import GRPC
import UIKit

class ViewModel: NSObject {
    internal static let rpc = Rpc()
}

@objc
protocol ViewModelDelegate where Self: UIViewController {
    func errorKey(for code: Int, with message: String?) -> String?
}

extension ViewModelDelegate {
    func onError(_ error: Error, canAutoDisconnect autoDisconnect: Bool = true) {
        let key: String?
        guard let status = error as? GRPCStatus else { return showAlert("Error") }

        switch status.code {
        case .unavailable:
            key = "Error.Unavailable"

        case .unauthenticated:
            if autoDisconnect, Keychain.authToken.get() != nil {
                key = nil

                if Keychain.authToken.delete() {
                    setCurrentUser(nil)
                }
            } else {
                key = errorKey(for: status.code.rawValue, with: status.message)
            }

        default:
            key = errorKey(for: status.code.rawValue, with: status.message)
        }

        if let key = key {
            showAlert(key)
        }
    }

    private func showAlert(_ key: String) {
        DispatchQueue.main.async { self.presentBasicAlert(text: key, feedback: .error) }
    }
}
