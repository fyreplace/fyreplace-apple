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

    func insert(_ item: Any, at index: Int)

    func update(_ item: Any, at index: Int)

    func remove(at index: Int)
}

class ItemLister<Item, Items, Service>: ItemListerProtocol
    where Items: ItemBundle, Item == Items.Item,
    Service: ItemListerService, Item == Service.Item, Items == Service.Items
{
    let pageSize: UInt32 = 12
    var itemCount: Int { items.count }
    private(set) var items: [Item] = []
    private let delegate: ItemListerDelegate
    private let service: Service
    private let forward: Bool
    private let type: Int
    private var stream: BidirectionalStreamingCall<FPPage, Items>?
    private var nextCursor = FPCursor.with { $0.isNext = true }
    private var state = ItemsState.incomplete
    private var residualFetch = false

    init(delegatingTo delegate: ItemListerDelegate, using service: Service, forward: Bool, type: Int = 0) {
        self.delegate = delegate
        self.service = service
        self.forward = forward
        self.type = type
    }

    deinit {
        stopListing()
    }

    func startListing() {
        stream = service.listItems(type: type, handler: onFetch(items:))
        let header = FPHeader.with {
            $0.forward = self.forward
            $0.size = pageSize
        }
        _ = stream!.sendMessage(.with { $0.header = header })
    }

    func stopListing() {
        _ = stream?.sendEnd()
    }

    func reset() {
        items.removeAll()
        nextCursor = .with { $0.isNext = true }
        residualFetch = state == .fetching
        state = .incomplete
    }

    func fetchMore() {
        guard state == .incomplete, let stream = stream else { return }
        state = .fetching
        _ = stream.sendMessage(.with { $0.cursor = nextCursor })
    }

    func insert(_ item: Any, at index: Int) {
        items.insert(item as! Item, at: index)
    }

    func update(_ item: Any, at index: Int) {
        items[index] = item as! Item
    }

    func remove(at index: Int) {
        items.remove(at: index)
    }

    private func onFetch(items: Items) {
        DispatchQueue.main.async { [self] in
            guard !residualFetch else {
                residualFetch = false
                return
            }

            self.items.append(contentsOf: items.items)
            nextCursor = items.next
            state = items.hasNext ? .incomplete : .complete
            delegate.onFetch(count: items.items.count)
        }
    }
}

enum ItemsState {
    case incomplete
    case complete
    case fetching
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

    func listItems(type: Int, handler: @escaping (Items) -> Void) -> BidirectionalStreamingCall<FPPage, Items>
}

@objc
protocol ItemListerDelegate {
    func onFetch(count: Int)
}
