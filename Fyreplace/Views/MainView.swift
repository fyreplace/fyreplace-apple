import SwiftUI

protocol MainViewProtocol: StatefulProtocol where State == MainView.State {}

@MainActor
extension MainViewProtocol {
    func addError(_ error: UnexpectedError) {
        state.errors.append(error)
        tryShowSomething()
    }

    func removeError() async {
        state.errors.removeFirst()
        await wait()
        tryShowSomething()
    }

    func addFailure(_ failure: FailureEvent) {
        state.failures.append(failure)
        tryShowSomething()
    }

    func removeFailure() async {
        state.failures.removeFirst()
        await wait()
        tryShowSomething()
    }

    private func wait() async {
        try? await Task.sleep(for: .milliseconds(100))
    }

    private func tryShowSomething() {
        if !state.errors.isEmpty {
            state.showError = true
        } else if !state.failures.isEmpty {
            state.showFailure = true
        }
    }
}

struct MainView: View, MainViewProtocol {
    let eventBus: EventBus

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

    @StateObject
    var state = State()

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
                isPresented: $state.showError,
                error: state.errors.first
            ) {
                Button("Ok", role: .cancel) {
                    Task {
                        await removeError()
                    }
                }
            }
            .alert(
                state.failures.first?.title ?? "",
                isPresented: $state.showFailure,
                presenting: state.failures.first,
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

    final class State: ObservableObject {
        @Published
        var showError = false

        @Published
        var showFailure = false

        @Published
        var errors: [UnexpectedError] = []

        @Published
        var failures: [FailureEvent] = []
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
