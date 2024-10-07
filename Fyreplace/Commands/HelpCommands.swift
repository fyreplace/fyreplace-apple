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
        Link("App.Help.Website", destination: config.app.info.website)
        Link("App.Help.TermsOfService", destination: config.app.info.termsOfService)
        Link("App.Help.PrivacyPolicy", destination: config.app.info.privacyPolicy)
        Link("App.Help.SourceCode", destination: config.app.info.sourceCode)
    }
}
