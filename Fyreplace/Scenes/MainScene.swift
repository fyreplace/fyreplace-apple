import SwiftUI

struct MainScene: Scene {
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
