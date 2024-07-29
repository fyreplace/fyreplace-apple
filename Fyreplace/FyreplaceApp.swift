import Combine
import Sentry
import SwiftUI

@main
struct FyreplaceApp: App {
    init() {
        if ProcessInfo.processInfo.arguments.contains("--ui-tests"),
           let bundleId = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleId)
        }

        guard let dsn = Config.default.sentry.dsn, !dsn.isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = Config.default.version.environment
        }
    }

    var body: some Scene {
        let destinationsSubject = PassthroughSubject<Destination, Never>()

        WindowGroup {
            MainView(destinationCommands: destinationsSubject.eraseToAnyPublisher())
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
            DestinationCommands(subject: destinationsSubject)
            HelpCommands()
        }
    }
}
