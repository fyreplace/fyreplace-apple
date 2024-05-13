import SwiftUI

@main
struct FyreplaceApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .commands {
            SidebarCommands()
            ToolbarCommands()
            CommandGroup(replacing: .help) {
                Link(destination: Config.main.websiteLink) {
                    Text("App.Help.Website")
                }
                Link(destination: Config.main.termsOfServiceLink) {
                    Text("App.Help.TermsOfService")
                }
                Link(destination: Config.main.privacyPolicyLink) {
                    Text("App.Help.PrivacyPolicy")
                }
            }
        }
    }
}
