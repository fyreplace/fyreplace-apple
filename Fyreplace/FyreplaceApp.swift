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
            #if DEBUG
                $0.tracesSampleRate = 1
                $0.profilesSampleRate = 1
                $0.enableSpotlight = true
            #endif
        }
    }

    var body: some Scene {
        let eventBus = EventBus()

        WindowGroup {
            EnvironmentView(eventBus: eventBus)
                .handlesExternalEvents(preferring: [], allowing: ["*"])
        }
        .handlesExternalEvents(matching: ["*"])
        .commands {
            ToolbarCommands()
            SidebarCommands()
            DestinationCommands(eventBus: eventBus)
            HelpCommands()
        }
        #if !os(macOS)
            .backgroundTask(
                .appRefresh("app.fyreplace.Fyreplace.tokenRefresh"),
                action: tokenRefreshBackgroundTask
            )
        #endif
    }
}
