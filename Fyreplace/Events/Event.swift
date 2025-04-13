import SwiftUI

@MainActor
enum Event: Sendable {
    case error(description: LocalizedStringResource = CriticalError.defaultDescription)
    case failure(title: LocalizedStringResource, text: LocalizedStringResource)
    case authorizationIssue
    case navigationShortcut(destination: Destination)
    case randomCode(_ code: String)
}

struct CriticalError: LocalizedError {
    static let defaultDescription: LocalizedStringResource = "Error.Unknown"

    var description: LocalizedStringResource

    var errorDescription: String {
        .init(localized: description)
    }
}

struct Failure: Sendable {
    let title: LocalizedStringResource
    let text: LocalizedStringResource
}
