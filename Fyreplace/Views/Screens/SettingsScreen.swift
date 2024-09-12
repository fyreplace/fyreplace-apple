import SwiftUI

struct SettingsScreen: View, SettingsScreenProtocol {
    @KeychainStorage("connection.token")
    var token

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
