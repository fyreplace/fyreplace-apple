import Foundation
import GRPC

class ViewModel: NSObject {
    internal static let rpc = Rpc()
}

@objc
protocol ViewModelDelegate: NSObjectProtocol {
    func onFailure(_ error: Error)
}

extension ViewModelDelegate {
    func onError(_ error: Error) {
        guard let status = error as? GRPCStatus,
              status.code == .unauthenticated,
              !["timestamp_exceeded", "invalid_token"].contains(status.message),
              Keychain.authToken.get() != nil else {
            return onFailure(error)
        }

        setUser(nil)
        NotificationCenter.default.post(name: FPBUser.userDisconnectedNotification, object: self)
    }
}
