import GRPC

extension FPCommentServiceClient: ItemListerService {
    typealias Item = FPComment
    typealias Items = FPComments

    func listItems(handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return list(callOptions: .authenticated, handler: handler)
    }
}
