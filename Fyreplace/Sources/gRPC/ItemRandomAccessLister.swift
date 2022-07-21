import Foundation
import GRPC

@objc
protocol ItemRandomAccessListerProtocol {
    var pageSize: UInt32 { get }

    var itemCount: Int { get }

    var totalCount: Int { get }

    func startListing()

    func stopListing()

    func fetch(around index: Int)

    func insert(_ item: Any)

    func update(_ item: Any, at index: Int)
}

class ItemRandomAccessLister<Item, Items, Service>: ItemRandomAccessListerProtocol
    where Items: ItemRandomAccessBundle, Item == Items.Item,
    Service: ItemListerService, Item == Service.Item, Items == Service.Items
{
    let pageSize: UInt32 = 12
    var itemCount: Int { items.count }
    private(set) var items: [Int: Item] = [:]
    private(set) var totalCount = 0
    private var indexes = NSMutableOrderedSet()
    private weak var delegate: ItemRandomAccessListerDelegate!
    private let service: Service
    private let contextId: Data
    private let type: Int
    private var stream: BidirectionalStreamingCall<FPPage, Items>?
    private var state = ItemsState.incomplete

    init(delegatingTo delegate: ItemRandomAccessListerDelegate, using service: Service, contextId: Data, type: Int = 0) {
        self.delegate = delegate
        self.service = service
        self.contextId = contextId
        self.type = type
    }

    func startListing() {
        stream = service.listItems(type: type) { [unowned self] in onFetch(items: $0) }
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

    func fetch(around index: Int) {
        guard state != .complete, let stream = stream else { return }
        let index = index - (index % Int(pageSize))
        indexes.add(index)

        if state == .incomplete {
            state = .fetching
            _ = stream.sendMessage(.with { $0.offset = UInt32(index) })
        }
    }

    func insert(_ item: Any) {
        items[totalCount] = (item as! Item)
        totalCount += 1
    }

    func update(_ item: Any, at index: Int) {
        items[index] = (item as! Item)
    }

    private func onFetch(items: Items) {
        DispatchQueue.main.async { [unowned self] in
            let index = indexes.firstObject as! Int
            indexes.removeObject(at: 0)

            for (i, item) in items.items.enumerated() {
                self.items[index + i] = item
            }

            totalCount = Int(items.count)

            if let index = indexes.firstObject as? Int {
                _ = stream!.sendMessage(.with { $0.offset = UInt32(index) })
            } else {
                state = itemCount < totalCount ? .incomplete : .complete
            }

            delegate.onFetch(count: items.items.count, at: index)
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
    func onFetch(count: Int, at index: Int)
}
