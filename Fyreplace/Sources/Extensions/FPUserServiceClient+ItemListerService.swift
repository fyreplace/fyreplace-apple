import GRPC

extension FPUserServiceClient: ItemListerService {
    typealias Item = FPProfile
    typealias Items = FPProfiles

    func listItems(handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return listBlocked(callOptions: .authenticated, handler: handler)
    }
}
