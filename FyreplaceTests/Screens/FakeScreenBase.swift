@testable import Fyreplace

open class FakeScreenBase {
    var eventBus: EventBus
    var api: APIProtocol

    init(eventBus: EventBus, api: APIProtocol) {
        self.eventBus = eventBus
        self.api = api
    }
}
