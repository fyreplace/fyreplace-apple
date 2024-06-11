import Sentry
import SwiftUI

@main
struct FyreplaceApp: App {
    init() {
        guard let dsn = Config.main.sentry.dsn, !dsn.isEmpty else { return }
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = Config.main.version.environment()
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
                Link(destination: Config.main.fyreplace.website) {
                    Text("App.Help.Website")
                }
                Link(destination: Config.main.fyreplace.termsOfService) {
                    Text("App.Help.TermsOfService")
                }
                Link(destination: Config.main.fyreplace.privacyPolicy) {
                    Text("App.Help.PrivacyPolicy")
                }
            }
        }
    }
}
