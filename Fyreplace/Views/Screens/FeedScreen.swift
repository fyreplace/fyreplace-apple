import SwiftUI

struct FeedScreen: View {
    var body: some View {
        Text(Destination.feed.titleKey)
            .padding()
            .navigationTitle(Destination.feed.titleKey)
            .accessibilityIdentifier(Destination.feed.id)
    }
}

#Preview {
    NavigationStack {
        FeedScreen()
    }
}
