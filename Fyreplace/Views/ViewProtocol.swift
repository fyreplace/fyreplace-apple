import OpenAPIRuntime
import Sentry

protocol ViewProtocol {}

protocol LoadingViewProtocol: ViewProtocol {
    var isLoading: Bool { get nonmutating set }
}

@MainActor
extension ViewProtocol {
    func call(failOn eventBus: EventBus, action: () async throws -> Void) async {
        do {
            try await action()
        } catch is ClientError {
            eventBus.send(Event.error(ConnectionError()))
        } catch {
            eventBus.send(.error(UnknownError()))
            SentrySDK.capture(error: error)
        }
    }
}

@MainActor
extension LoadingViewProtocol {
    func callWhileLoading(failOn eventBus: EventBus, action: () async throws -> Void) async {
        isLoading = true
        await call(failOn: eventBus, action: action)
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
