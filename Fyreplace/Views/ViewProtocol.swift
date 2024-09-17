import OpenAPIRuntime
import Sentry

@MainActor
protocol ViewProtocol {
    var eventBus: EventBus { get }
}

@MainActor
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
            unfortunateEvent = .error(description: "Error.Connection")
        } catch {
            unfortunateEvent = .error()
        }

        if let event = unfortunateEvent {
            eventBus.send(event)

            if let event = unfortunateEvent as? ErrorEvent,
                event.description == ErrorEvent.defaultDescription
            {
                SentrySDK.capture(error: event)
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
