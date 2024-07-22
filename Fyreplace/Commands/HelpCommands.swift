import SwiftUI

struct HelpCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            HelpCommandsLinks()
        }
    }
}

private struct HelpCommandsLinks: View {
    @Environment(\.config)
    private var config

    var body: some View {
        Link(destination: config.app.info.website) {
            Text("App.Help.Website")
        }
        Link(destination: config.app.info.termsOfService) {
            Text("App.Help.TermsOfService")
        }
        Link(destination: config.app.info.privacyPolicy) {
            Text("App.Help.PrivacyPolicy")
        }
    }
}
