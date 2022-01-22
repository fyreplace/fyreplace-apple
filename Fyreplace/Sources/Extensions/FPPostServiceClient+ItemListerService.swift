import GRPC

extension FPPostServiceClient: ItemListerService {
    typealias Item = FPPost
    typealias Items = FPPosts

    func listItems(handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return listArchive(callOptions: .authenticated, handler: handler)
    }
}
