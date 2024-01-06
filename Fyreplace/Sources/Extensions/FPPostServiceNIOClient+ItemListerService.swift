import GRPC

extension FPPostServiceNIOClient: ItemListerService {
    typealias Item = FPPost
    typealias Items = FPPosts

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        switch type {
        case 1:
            return listOwnPosts(handler: handler)

        case 2:
            return listDrafts(handler: handler)

        default:
            return listArchive(handler: handler)
        }
    }
}
