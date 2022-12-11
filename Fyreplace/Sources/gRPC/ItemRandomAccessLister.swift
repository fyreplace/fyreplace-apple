import Foundation
import GRPC

@objc
protocol ItemRandomAccessListerProtocol: BaseListerProtocol {
    var totalCount: Int { get }

    func fetch(around position: Int)

    func insert(_ item: Any)

    func update(_ item: Any, at position: Int)
}

class ItemRandomAccessLister<Item, Items, Service>: ItemRandomAccessListerProtocol
    where Item: IdentifiableItem,
    Items: ItemRandomAccessBundle, Item == Items.Item,
    Service: ItemListerService, Item == Service.Item, Items == Service.Items
{
    let pageSize: UInt32 = 12
    var itemCount: Int { items.count }
    private(set) var items: [Int: Item] = [:]
    private(set) var totalCount = 0
    private var positions = NSMutableOrderedSet()
    private weak var delegate: ItemRandomAccessListerDelegate?
    private let service: Service
    private let contextId: Data
    private let type: Int
    private var stream: BidirectionalStreamingCall<FPPage, Items>?
    private var state = ItemsState.incomplete

    init(delegatingTo delegate: ItemRandomAccessListerDelegate?, using service: Service, contextId: Data, type: Int = 0) {
        self.delegate = delegate
        self.service = service
        self.contextId = contextId
        self.type = type
    }

    func startListing() {
        stream = service.listItems(type: type) { [weak self] in self?.onFetch(items: $0) }
        _ = stream?.sendMessage(.with {
            $0.header = .with {
                $0.forward = true
                $0.size = pageSize
                $0.contextID = contextId
            }
        })
    }

    func stopListing() {
        _ = stream?.sendEnd()
    }

    func getPosition(for item: Any) -> Int {
        let itemId = (item as! Item).id
        guard let position = (items.firstIndex { $0.1.id == itemId }) else { return -1 }
        return items[position].0
    }

    func fetch(around position: Int) {
        guard state != .complete, let stream = stream else { return }
        let pageStart = position - (position % Int(pageSize))
        positions.add(pageStart)

        if state == .incomplete {
            state = .fetching
            _ = stream.sendMessage(.with { $0.offset = UInt32(pageStart) })
        }
    }

    func insert(_ item: Any) {
        items[totalCount] = (item as! Item)
        totalCount += 1
    }

    func update(_ item: Any, at position: Int) {
        items[position] = (item as! Item)
    }

    private func onFetch(items: Items) {
        DispatchQueue.main.async { [self] in
            let position = positions.firstObject as! Int
            positions.removeObject(at: 0)

            for (i, item) in items.items.enumerated() {
                self.items[position + i] = item
            }

            let oldTotalCount = totalCount
            let newTotalCount = Int(items.count)
            totalCount = newTotalCount

            if let position = positions.firstObject as? Int {
                _ = stream!.sendMessage(.with { $0.offset = UInt32(position) })
            } else {
                state = itemCount < totalCount ? .incomplete : .complete
            }

            delegate?.itemRandomAccessLister(
                self,
                didFetch: items.items.count,
                at: position,
                oldTotal: oldTotalCount,
                newTotal: newTotalCount
            )
        }
    }
}

protocol ItemRandomAccessBundle {
    associatedtype Item

    var items: [Item] { get }
    var count: UInt32 { get }
}

@objc
protocol ItemRandomAccessListerDelegate {
    func itemRandomAccessLister(_ itemLister: ItemRandomAccessListerProtocol, didFetch count: Int, at position: Int, oldTotal: Int, newTotal: Int)
}
