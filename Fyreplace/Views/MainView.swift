import SwiftUI

struct MainView: View, MainViewProtocol {
    @State
    var showError = false

    @State
    var showFailure = false

    @State
    var errors: [UnexpectedError] = []

    @State
    var failures: [FailureEvent] = []

    @EnvironmentObject
    private var eventBus: EventBus

    @Environment(\.api)
    private var client

    @KeychainStorage("connection.token")
    private var token

    var body: some View {
        #if os(macOS)
            let navigation = RegularNavigation()
        #else
            let navigation = DynamicNavigation()
        #endif

        navigation
            .alert(
                isPresented: $showError,
                error: errors.first
            ) {
                Button("Ok", role: .cancel) {
                    Task {
                        await removeError()
                    }
                }
            }
            .alert(
                failures.first?.title ?? "",
                isPresented: $showFailure,
                presenting: failures.first,
                actions: { _ in
                    Button("Ok", role: .cancel) {
                        Task {
                            await removeFailure()
                        }
                    }
                }, message: { (failure: FailureEvent) in
                    Text(failure.text)
                }
            )
            .onReceive(eventBus.events.compactMap { ($0 as? ErrorEvent)?.error }, perform: addError)
            .onReceive(eventBus.events.compactMap { ($0 as? FailureEvent) }, perform: addFailure)
        #if os(macOS)
            .task { await keepRefreshingToken() }
        #endif
    }

    private func keepRefreshingToken() async {
        do {
            while true {
                try await Task.sleep(for: .seconds(tokenRefreshDelaySeconds))

                if let newToken = await refreshToken(using: client) {
                    token = newToken
                }
            }
        } catch {}
    }
}

#Preview {
    MainView()
}

struct ForegroundEnvironmentKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var isInForeground: Bool {
        get { self[ForegroundEnvironmentKey.self] }
        set { self[ForegroundEnvironmentKey.self] = newValue }
    }
}

struct APIClientEnvironmentKey: EnvironmentKey {
    static let defaultValue: APIProtocol = .fake()
}

extension EnvironmentValues {
    var api: APIProtocol {
        get { self[APIClientEnvironmentKey.self] }
        set { self[APIClientEnvironmentKey.self] = newValue }
    }
}
