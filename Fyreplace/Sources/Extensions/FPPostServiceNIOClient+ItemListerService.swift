import GRPC

extension FPPostServiceNIOClient: ItemListerService {
    typealias Item = FPPost
    typealias Items = FPPosts

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        switch type {
        case 1:
            return listOwnPosts(callOptions: .authenticated, handler: handler)

        case 2:
            return listDrafts(callOptions: .authenticated, handler: handler)

        default:
            return listArchive(callOptions: .authenticated, handler: handler)
        }
    }
}
