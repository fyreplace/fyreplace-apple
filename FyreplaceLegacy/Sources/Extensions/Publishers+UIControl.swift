import Combine
import UIKit

extension Publishers {
    struct ControlEvent<Control: UIControl>: Publisher {
        typealias Output = Void
        typealias Failure = Never

        private let control: Control
        private let events: UIControl.Event

        init(control: Control, events: UIControl.Event) {
            self.control = control
            self.events = events
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            let subscription = EventSubscription(control: control, events: events, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private final class EventSubscription<S: Subscriber, Control: UIControl>: Subscription where S.Input == Void, S.Failure == Never {
    weak private var control: Control?
    private let events: UIControl.Event
    private var subscriber: S?

    init(control: Control, events: UIControl.Event, subscriber: S) {
        self.control = control
        self.events = events
        self.subscriber = subscriber
        control.addTarget(self, action: #selector(handleEvent), for: events)
    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        control?.removeTarget(self, action: #selector(handleEvent), for: events)
        subscriber = nil
    }

    @objc
    private func handleEvent() {
        _ = subscriber?.receive(())
    }
}
