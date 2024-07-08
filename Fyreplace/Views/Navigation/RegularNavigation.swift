import SwiftUI

struct RegularNavigation: View {
    @SceneStorage("RegularNavigation.selectedDestination")
    private var selectedDestination: Destination?

    var body: some View {
        NavigationSplitView {
            List(Destination.all, selection: $selectedDestination) { destination in
                NavigationLink(value: destination) {
                    Label(destination)
                }
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 180)
            #endif
        } detail: {
            NavigationStack {
                Screen(destination: selectedDestination ?? .feed)
            }
        }
    }
}

#Preview {
    RegularNavigation()
}
