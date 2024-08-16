import Combine
import Sentry
import SwiftUI

@main
struct FyreplaceApp: App {
    init() {
        guard let dsn = Config.default.sentry.dsn, !dsn.isEmpty else { return }

        SentrySDK.start {
            $0.dsn = dsn
            $0.environment = Config.default.version.environment
        }
    }

    var body: some Scene {
        let eventBus = EventBus()

        WindowGroup {
            EnvironmentView(eventBus: eventBus)
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
            DestinationCommands(eventBus: eventBus)
            HelpCommands()
        }
        #if !os(macOS)
        .backgroundTask(.appRefresh("app.fyreplace.Fyreplace.tokenRefresh"), action: tokenRefreshBackgroundTask)
        #endif
    }
}
