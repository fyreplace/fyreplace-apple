import Foundation
import GRPC

class ViewModel: NSObject {
    internal static let rpc = Rpc()
}

@objc
protocol ViewModelDelegate: NSObjectProtocol {
    func onFailure(_ error: Error)
}

extension ViewModelDelegate where Self: UIViewController {
    func onError(_ error: Error) {
        guard let status = error as? GRPCStatus else { return onFailureAsync(error) }

        switch status.code {
        case .unavailable:
            presentBasicAlert(text: "Error.Unavailable", feedback: .error)

        case .unauthenticated:
            if !["timestamp_exceeded", "invalid_token"].contains(status.message) && Keychain.authToken.get() != nil {
                setUser(nil)
                NotificationCenter.default.post(name: FPUser.userDisconnectedNotification, object: self)
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
