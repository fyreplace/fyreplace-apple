@testable import Fyreplace

class StoringEventBus: EventBus {
    var storedEvents: [Event] = []

    override func send(_ event: Event) {
        super.send(event)
        storedEvents.append(event)
    }
}

extension Event {
    var isFailure: Bool {
        if case .failure = self {
            return true
        } else {
            return false
        }
    }
}
