import Foundation
import GRPC

class ViewModel: NSObject {
    internal static let rpc = Rpc()
}

@objc
protocol ViewModelDelegate where Self: UIViewController {
    func onFailure(_ error: Error)
}

extension ViewModelDelegate {
    func onError(_ error: Error) {
        guard let status = error as? GRPCStatus else { return onFailureAsync(error) }

        switch status.code {
        case .unavailable:
            presentBasicAlert(text: "Error.Unavailable", feedback: .error)

        case .unauthenticated:
            if !["timestamp_exceeded", "invalid_token"].contains(status.message) && Keychain.authToken.get() != nil {
                if (Keychain.authToken.delete()) {
                    setUser(nil)
                }
            } else {
                onFailureAsync(status)
            }

        default:
            onFailureAsync(status)
        }
    }

    private func onFailureAsync(_ error: Error) {
        DispatchQueue.main.async { self.onFailure(error) }
    }
}
