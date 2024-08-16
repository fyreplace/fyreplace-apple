import SwiftUI

struct SettingsScreen: View, SettingsScreenProtocol {
    @KeychainStorage("connection.token")
    var token

    @SceneStorage("SettingsScreen.choice")
    private var choice = Destination.login

    var body: some View {
        Button("Settings.Logout", role: .destructive, action: logout)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
