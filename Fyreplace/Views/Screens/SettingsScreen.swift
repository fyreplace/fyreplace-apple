import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        Text(Destination.settings.titleKey)
            .padding()
            .navigationTitle(Destination.settings.titleKey)
            .accessibilityIdentifier(Destination.settings.id)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
