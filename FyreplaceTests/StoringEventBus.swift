@testable import Fyreplace

class StoringEventBus: EventBus {
    var storedEvents: [Event] = []

    override func send(_ event: Event) {
        super.send(event)
        storedEvents.append(event)
    }
}
