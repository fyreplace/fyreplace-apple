import GRPC

extension FPNotificationServiceNIOClient: ItemListerService {
    typealias Item = FPNotification
    typealias Items = FPNotifications

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items> {
        return list(callOptions: .authenticated, handler: handler)
    }
}
