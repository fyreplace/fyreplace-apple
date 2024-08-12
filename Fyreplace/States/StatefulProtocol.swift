import OpenAPIRuntime
import Sentry

protocol StatefulProtocol {
    associatedtype State

    var state: State { get }
}

@MainActor
extension StatefulProtocol {
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
extension StatefulProtocol where State: LoadingViewState {
    func callWhileLoading(failOn eventBus: EventBus, action: () async throws -> Void) async {
        state.isLoading = true
        await call(failOn: eventBus, action: action)
        state.isLoading = false
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
