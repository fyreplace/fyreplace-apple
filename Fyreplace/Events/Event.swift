import SwiftUI

@MainActor
protocol Event: Sendable {}

@MainActor
protocol UnfortunateEvent: Event {}

struct ErrorEvent: UnfortunateEvent, LocalizedError {
    static let defaultDescription: String.LocalizationValue = "Error.Unknown"

    var description = defaultDescription

    var errorDescription: String {
        .init(localized: description)
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

struct AuthorizationIssueEvent: UnfortunateEvent {}

extension Event {
    typealias authorizationIssue = AuthorizationIssueEvent
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
