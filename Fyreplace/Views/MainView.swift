import SwiftUI

struct MainView: View, MainViewProtocol {
    let eventBus: EventBus

    @State
    var showError = false

    @State
    var showFailure = false

    @State
    var errors: [UnexpectedError] = []

    @State
    var failures: [FailureEvent] = []

    @Environment(\.config)
    private var config

    #if os(macOS)
        @Environment(\.controlActiveState)
        private var status
    #else
        @Environment(\.scenePhase)
        private var status
    #endif

    @AppStorage("connection.environment")
    private var environment = ServerEnvironment.default

    var body: some View {
        #if os(macOS)
            let navigation = RegularNavigation()
        #else
            let navigation = DynamicNavigation()
        #endif

        navigation
            .environment(\.isInForeground, status != .inactive)
            .environment(\.api, config.app.api.client(for: environment))
            .environmentObject(eventBus)
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
            .onReceive(eventBus.events.compactMap { ($0 as? ErrorEvent)?.error }, perform: addError(_:))
            .onReceive(eventBus.events.compactMap { ($0 as? FailureEvent) }, perform: addFailure(_:))
    }
}

#Preview {
    MainView(eventBus: .init())
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
