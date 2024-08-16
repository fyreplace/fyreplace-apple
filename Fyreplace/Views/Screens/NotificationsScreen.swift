import SwiftUI

struct NotificationsScreen: View {
    var body: some View {
        Text(Destination.notifications.titleKey)
            .padding()
            .navigationTitle(Destination.notifications.titleKey)
    }
}

#Preview {
    NavigationStack {
        NotificationsScreen()
    }
}
