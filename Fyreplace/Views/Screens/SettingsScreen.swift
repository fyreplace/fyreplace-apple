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
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
