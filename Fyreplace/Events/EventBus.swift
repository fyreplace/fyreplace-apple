import Combine
import SwiftUI

class EventBus: ObservableObject {
    private let subject = PassthroughSubject<Event, Never>()

    let events: AnyPublisher<Event, Never>

    init() {
        events = subject.eraseToAnyPublisher()
    }

    @MainActor
    func send(_ event: Event) {
        subject.send(event)
    }
}
