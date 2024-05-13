import SwiftUI

struct PublishedScreen: View {
    var body: some View {
        Text(Destination.published.titleKey)
            .padding()
            .navigationTitle(Destination.published.titleKey)
            .accessibilityIdentifier(Destination.published.id)
    }
}

#Preview {
    NavigationStack {
        PublishedScreen()
    }
}
