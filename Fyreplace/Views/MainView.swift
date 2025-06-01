import SwiftUI

struct MainView: View, MainViewProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api

    @State
    var showError = false

    @State
    var showFailure = false

    @State
    var showEmailVerified = false

    @State
    var errors: [CriticalError] = []

    @State
    var failures: [Failure] = []

    @State
    var verifiedEmail = ""

    @KeychainStorage("connection.token")
    var token

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
                Button("Ok") {
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
                    Button("Ok") {
                        Task {
                            await removeFailure()
                        }
                    }
                },
                message: { (failure: Failure) in
                    Text(failure.text)
                }
            )
            .alert("Main.EmailVerified.Title", isPresented: $showEmailVerified) {
                Button("Ok") {}
            } message: {
                Text("Main.EmailVerified.Message:\(verifiedEmail)")
            }
            .onReceive(eventBus.events, perform: handle)
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
