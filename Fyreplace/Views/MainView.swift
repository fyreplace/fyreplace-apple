import SwiftUI

struct MainView: View, MainViewProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @State
    var showError = false

    @State
    var showFailure = false

    @State
    var errors: [CriticalError] = []

    @State
    var failures: [Failure] = []

    @Environment(\.api)
    private var api

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
                String(localized: failures.first?.title ?? ""),
                isPresented: $showFailure,
                presenting: failures.first,
                actions: { _ in
                    Button("Ok", role: .cancel) {
                        Task {
                            await removeFailure()
                        }
                    }
                },
                message: { (failure: Failure) in
                    Text(failure.text)
                }
            )
            .onReceive(eventBus.events) {
                switch $0 {
                case let .error(description):
                    addError(.init(description: description))
                case let .failure(title, text):
                    addFailure(.init(title: title, text: text))
                case .authorizationIssue:
                    token = ""
                    eventBus.send(.failure(title: "Error.Unauthorized.Title", text: "Error.Unauthorized.Text"))
                default:
                    break
                }
            }
            #if os(macOS)
                .task { await keepRefreshingToken() }
            #endif
    }

    private func keepRefreshingToken() async {
        do {
            while true {
                try await Task.sleep(for: .seconds(tokenRefreshDelaySeconds))

                if let newToken = await refreshToken(using: api) {
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

struct APIEnvironmentKey: EnvironmentKey {
    static let defaultValue: APIProtocol = .fake()
}

extension EnvironmentValues {
    var api: APIProtocol {
        get { self[APIEnvironmentKey.self] }
        set { self[APIEnvironmentKey.self] = newValue }
    }
}
