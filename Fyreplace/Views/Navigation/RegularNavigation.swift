import SwiftUI

struct RegularNavigation: View {
    #if os(macOS)
        @SceneStorage("RegularNavigation.selectedDestination")
        private var selectedDestination = Destination.feed
    #else
        @SceneStorage("RegularNavigation.selectedDestination")
        private var selectedDestination: Destination?
    #endif

    private var finalDestination: Destination {
        #if os(macOS)
            selectedDestination
        #else
            selectedDestination ?? .feed
        #endif
    }

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
                Screen(destination: finalDestination)
            }
        }
    }
}

#Preview {
    RegularNavigation()
}
