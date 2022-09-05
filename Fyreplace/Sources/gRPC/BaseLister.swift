import Foundation

@objc
protocol BaseListerProtocol {
    var pageSize: UInt32 { get }

    var itemCount: Int { get }

    func startListing()

    func stopListing()

    func getPosition(for item: Any) -> Int
}
