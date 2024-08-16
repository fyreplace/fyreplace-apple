import SwiftUI

struct ArchiveScreen: View {
    var body: some View {
        Text(Destination.archive.titleKey)
            .padding()
            .navigationTitle(Destination.archive.titleKey)
    }
}

#Preview {
    NavigationStack {
        ArchiveScreen()
    }
}
