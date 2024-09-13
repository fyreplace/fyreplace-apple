import OpenAPIRuntime
import Sentry

protocol ViewProtocol {
    var eventBus: EventBus { get }
}

protocol LoadingViewProtocol: ViewProtocol {
    var isLoading: Bool { get nonmutating set }
}

@MainActor
extension ViewProtocol {
    func call(action: () async throws -> UnfortunateEvent?) async {
        let unfortunateEvent: UnfortunateEvent?

        do {
            unfortunateEvent = try await action()
        } catch is ClientError {
            unfortunateEvent = .error(ConnectionError())
        } catch {
            unfortunateEvent = .error(UnknownError())
        }

        if let event = unfortunateEvent {
            eventBus.send(event)

            if let event = unfortunateEvent as? ErrorEvent {
                SentrySDK.capture(error: event.error)
            }
        }
    }
}

@MainActor
extension LoadingViewProtocol {
    func callWhileLoading(action: () async throws -> UnfortunateEvent?) async {
        isLoading = true
        await call(action: action)
        isLoading = false
    }
}

class UnexpectedError: LocalizedError {
    var errorDescription: String? {
        nil
    }
}

class ConnectionError: UnexpectedError {
    override var errorDescription: String {
        .init(localized: "Error.Connection")
    }
}

class UnknownError: UnexpectedError {
    override var errorDescription: String? {
        .init(localized: "Error.Unknown")
    }
}
