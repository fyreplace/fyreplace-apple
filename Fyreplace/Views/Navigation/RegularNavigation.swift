import SwiftUI

struct RegularNavigation: View {
    @EnvironmentObject
    private var eventBus: EventBus

    @Environment(\.isInForeground)
    private var isInForeground

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
        .onReceive(
            eventBus.events
                .filter { _ in isInForeground }
                .compactMap { $0 as? NavigationShortcutEvent }
        ) {
            selectedDestination = $0.destination
        }
    }
}

#Preview {
    RegularNavigation()
}
