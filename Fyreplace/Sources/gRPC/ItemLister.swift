import Foundation
import GRPC

@objc
protocol ItemListerProtocol {
    var pageSize: UInt32 { get }

    var itemCount: Int { get }

    func startListing()

    func stopListing()

    func reset()

    func fetchMore()
}

class ItemLister<Item, Items, Service>: ItemListerProtocol
    where Items: ItemBundle, Item == Items.Item,
          Service: ItemListerService, Item == Service.Item,
          Items == Service.Items {
    let pageSize: UInt32 = 12
    var itemCount: Int { items.count }
    private(set) var items: [Item] = []
    private let delegate: ItemListerDelegate
    private let service: Service
    private var stream: BidirectionalStreamingCall<FPPage, Items>?
    private var nextCursor: FPCursor?
    private var fetching = false

    init(delegatingTo delegate: ItemListerDelegate, using service: Service) {
        self.delegate = delegate
        self.service = service
    }

    deinit {
        stopListing()
    }

    func startListing() {
        stream = service.listItems(handler: onFetch(items:))
        let header = FPHeader.with {
            $0.forward = false
            $0.size = pageSize
        }
        _ = stream?.sendMessage(.with { $0.header = header })
    }

    func stopListing() {
        _ = stream?.sendEnd()
    }

    func reset() {
        items.removeAll()
        nextCursor = nil
    }

    func fetchMore() {
        guard let stream = stream, !fetching else { return }
        fetching = true
        let cursor = nextCursor ?? .with { $0.isNext = true }
        _ = stream.sendMessage(.with { $0.cursor = cursor })
    }

    private func onFetch(items: Items) {
        self.items.append(contentsOf: items.items)
        self.nextCursor = items.next

        DispatchQueue.main.async { [self] in
            fetching = false
            delegate.onFetch(count: items.items.count)

            if !items.hasNext {
                delegate.onEnd()
            }
        }
    }
}

protocol ItemBundle {
    associatedtype Item

    var items: [Item] { get }
    var previous: FPCursor { get }
    var hasPrevious: Bool { get }
    var next: FPCursor { get }
    var hasNext: Bool { get }
}

protocol ItemListerService {
    associatedtype Item
    associatedtype Items

    func listItems(handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items>
}

@objc
protocol ItemListerDelegate {
    func onFetch(count: Int)

    func onEnd()
}
