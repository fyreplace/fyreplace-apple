import SwiftUI

struct NotificationsScreen: View {
    var body: some View {
        Text(Destination.notifications.titleKey)
            .padding()
            .navigationTitle(Destination.notifications.titleKey)
            .accessibilityIdentifier(Destination.notifications.id)
    }
}

#Preview {
    NavigationStack {
        NotificationsScreen()
    }
}
