import SwiftUI

struct DraftsScreen: View {
    var body: some View {
        Text(Destination.drafts.titleKey)
            .padding()
            .navigationTitle(Destination.drafts.titleKey)
            .accessibilityIdentifier(Destination.drafts.id)
    }
}

#Preview {
    NavigationStack {
        DraftsScreen()
    }
}
