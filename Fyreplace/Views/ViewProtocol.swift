import OpenAPIRuntime
import Sentry

@MainActor
protocol ViewProtocol {
    var eventBus: EventBus { get }
}

@MainActor
protocol APIViewProtocol: ViewProtocol {
    var api: APIProtocol { get }
}

@MainActor
protocol LoadingViewProtocol: APIViewProtocol {
    var isLoading: Bool { get nonmutating set }
}

@MainActor
extension ViewProtocol {
    func call(action: () async throws -> Event?) async {
        let unfortunateEvent: Event?

        do {
            unfortunateEvent = try await action()
        } catch is ClientError {
            unfortunateEvent = .error(description: "Error.Connection")
        } catch {
            unfortunateEvent = .error()
        }

        guard let unfortunateEvent else { return }
        eventBus.send(unfortunateEvent)
        
        if case let .error(error) = unfortunateEvent,
           error == CriticalError.defaultDescription
        {
            SentrySDK.capture(error: CriticalError(description: error))
        }
    }
}

@MainActor
extension LoadingViewProtocol {
    func callWhileLoading(action: () async throws -> Event?) async {
        isLoading = true
        await call(action: action)
        isLoading = false
    }
}
