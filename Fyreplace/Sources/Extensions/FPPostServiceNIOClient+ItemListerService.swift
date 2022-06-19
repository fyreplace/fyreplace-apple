import GRPC

extension FPPostServiceNIOClient: ItemListerService {
    typealias Item = FPPost
    typealias Items = FPPosts

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return type == 0
            ? listArchive(callOptions: .authenticated, handler: handler)
            : listDrafts(callOptions: .authenticated, handler: handler)
    }
}
