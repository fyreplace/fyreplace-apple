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
        DispatchQueue.main.async { [unowned self] in
            onFailure(error, canAutoDisconnect: autoDisconnect)
        }
    }

    func onFailure(_ error: Error, canAutoDisconnect autoDisconnect: Bool) {
        let key: String?
        guard let status = error as? GRPCStatus else {
            return presentBasicAlert(text: "Error", feedback: .error)
        }

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
            presentBasicAlert(text: key, feedback: .error)
        }
    }
}
