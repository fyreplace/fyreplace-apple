import SwiftUI

struct SettingsScreen: View {
    @SceneStorage("SettingsScreen.choice")
    private var choice = Destination.login

    var body: some View {
        MultiChoiceScreen(
            choices: [.login, .register],
            choice: $choice
        )
        .navigationTitle("")
        #if os(macOS)
            .animation(.snappy, value: choice)
        #endif
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
