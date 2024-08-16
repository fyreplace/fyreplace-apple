import SwiftUI

struct SettingsScreen: View {
    @SceneStorage("SettingsScreen.choice")
    private var choice = Destination.login

    @AppStorage("account.identifier")
    private var identifier = ""

    @AppStorage("account.username")
    private var username = ""

    @AppStorage("account.email")
    private var email = ""

    @AppStorage("account.isWaitingForRandomCode")
    private var isWaitingForRandomCode = false

    @KeychainStorage("connection.token")
    private var token

    var body: some View {
        Button("Settings.Logout", role: .destructive, action: logout)
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
    }

    private func logout() {
        identifier = ""
        username = ""
        email = ""
        isWaitingForRandomCode = false
        token = ""
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
