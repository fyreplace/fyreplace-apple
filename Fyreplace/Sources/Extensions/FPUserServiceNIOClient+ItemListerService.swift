import GRPC

extension FPUserServiceNIOClient: ItemListerService {
    typealias Item = FPProfile
    typealias Items = FPProfiles

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return listBlocked(callOptions: .authenticated, handler: handler)
    }
}
