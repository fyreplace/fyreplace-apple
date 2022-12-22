import Foundation
import GRPC

@objc
protocol ItemListerProtocol: BaseListerProtocol {
    var manuallyAddedCount: Int { get }

    func reset()

    func fetchMore()

    func insert(_ item: Any, at position: Int)

    func update(_ item: Any, at position: Int)

    func remove(at position: Int)
}

class ItemLister<Item, Items, Service>: ItemListerProtocol
    where Item: IdentifiableItem,
    Items: ItemBundle, Item == Items.Item,
    Service: ItemListerService, Item == Service.Item, Items == Service.Items
{
    let pageSize: UInt32 = 12
    var itemCount: Int { items.count }
    private(set) var items: [Item] = []
    private(set) var manuallyAddedCount = 0
    private weak var delegate: ItemListerDelegate?
    private let service: Service
    private let forward: Bool
    private let type: Int
    private var stream: BidirectionalStreamingCall<FPPage, Items>?
    private var nextCursor = FPCursor.with { $0.isNext = true }
    private var state = ItemsState.paused

    init(delegatingTo delegate: ItemListerDelegate?, using service: Service, forward: Bool, type: Int = 0) {
        self.delegate = delegate
        self.service = service
        self.forward = forward
        self.type = type
    }

    deinit {
        stopListing()
    }

    func startListing() {
        stream = service.listItems(type: type) { [weak self] in self?.onFetch(items: $0) }

        let header = FPHeader.with {
            $0.forward = self.forward
            $0.size = pageSize
        }

        if state == .paused {
            state = .incomplete
        }

        _ = stream!.sendMessage(.with { $0.header = header })
    }

    func stopListing() {
        if state != .complete {
            state = .paused
        }

        _ = stream?.sendEnd()
    }

    func getPosition(for item: Any) -> Int {
        let itemId = (item as! IdentifiableItem).id
        return items.firstIndex { $0.id == itemId } ?? -1
    }

    func reset() {
        items.removeAll()
        nextCursor = .with { $0.isNext = true }
        manuallyAddedCount = 0

        if state != .paused {
            state = .incomplete
        }
    }

    func fetchMore() {
        guard state == .incomplete, let stream else { return }
        state = .fetching
        _ = stream.sendMessage(.with { $0.cursor = nextCursor })
    }

    func insert(_ item: Any, at position: Int) {
        items.insert(item as! Item, at: position)
        manuallyAddedCount += 1
    }

    func update(_ item: Any, at position: Int) {
        items[position] = item as! Item
    }

    func remove(at position: Int) {
        items.remove(at: position)
        manuallyAddedCount -= 1
    }

    private func onFetch(items: Items) {
        DispatchQueue.main.async { [self] in
            guard state == .fetching else { return }
            self.items.append(contentsOf: items.items)
            nextCursor = items.next
            state = items.hasNext ? .incomplete : .complete
            delegate?.itemLister(self, didFetch: items.items.count)
        }
    }
}

enum ItemsState {
    case incomplete
    case complete
    case fetching
    case paused
}

protocol IdentifiableItem {
    var id: Data { get }
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
    func itemLister(_ itemLister: ItemListerProtocol, didFetch count: Int)
}
