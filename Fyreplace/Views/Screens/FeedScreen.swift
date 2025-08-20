import SwiftUI

struct FeedScreen: View {
    var body: some View {
        Text(Destination.feed.titleKey)
            .padding()
            .navigationTitle(Destination.feed.titleKey)
    }
}

#Preview {
    NavigationStack {
        FeedScreen()
    }
}
