import SwiftUI

protocol Event {}

protocol UnfortunateEvent: Event {}

struct ErrorEvent: UnfortunateEvent {
    let error: UnexpectedError

    init(_ error: UnexpectedError) {
        self.error = error
    }
}

extension Event {
    typealias error = ErrorEvent
}

struct FailureEvent: UnfortunateEvent {
    let title: LocalizedStringKey
    let text: LocalizedStringKey
}

extension Event {
    typealias failure = FailureEvent
}

struct NavigationShortcutEvent: Event {
    let destination: Destination

    init(to destination: Destination) {
        self.destination = destination
    }
}

extension Event {
    typealias navigationShortcut = NavigationShortcutEvent
}

struct RandomCodeEvent: Event {
    let randomCode: String

    init(_ randomCode: String) {
        self.randomCode = randomCode
    }
}

extension Event {
    typealias randomCode = RandomCodeEvent
}
