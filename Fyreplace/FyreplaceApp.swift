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
        WindowGroup {
            MainView()
        }
        .commands {
            SidebarCommands()
            ToolbarCommands()
            CommandGroup(replacing: .help) {
                Link(destination: Config.default.app.info.website) {
                    Text("App.Help.Website")
                }
                Link(destination: Config.default.app.info.termsOfService) {
                    Text("App.Help.TermsOfService")
                }
                Link(destination: Config.default.app.info.privacyPolicy) {
                    Text("App.Help.PrivacyPolicy")
                }
            }
        }
    }
}
