import SwiftUI

struct EnvironmentView: View {
    let eventBus: EventBus

    #if os(macOS)
        @Environment(\.controlActiveState)
        private var status
    #else
        @Environment(\.scenePhase)
        private var status
    #endif

    @Environment(\.config)
    private var config

    @AppStorage("connection.environment")
    private var environment = ServerEnvironment.default

    var body: some View {
        MainView()
            .environment(\.isInForeground, status != .inactive)
            .environment(\.api, config.app.api.client(for: environment))
            .environmentObject(eventBus)
    }
}

extension EnvironmentValues {
    @Entry var isInForeground = true
    @Entry var api: APIProtocol = .fake()
}
