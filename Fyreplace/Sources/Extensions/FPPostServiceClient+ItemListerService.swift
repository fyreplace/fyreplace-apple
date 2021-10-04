import GRPC

extension FPPostServiceClient: ItemListerService {
    typealias Item = FPPost
    typealias Items = FPPosts

    func listItems(handler: @escaping (FPPosts) -> Void) -> BidirectionalStreamingCall<FPPage, FPPosts> {
        return listArchive(callOptions: .authenticated, handler: handler)
    }
}
