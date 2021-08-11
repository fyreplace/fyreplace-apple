import Foundation
import GRPC

class ViewModel: NSObject {
    internal static let rpc = Rpc()
}

@objc
protocol ViewModelDelegate {
    func onFailure(_ error: Error)
}
