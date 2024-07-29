import Combine
import SwiftUI

struct MainView: View {
    var destinationCommands: AnyPublisher<Destination, Never>

    #if os(macOS)
        @Environment(\.controlActiveState)
        private var status
    #else
        @Environment(\.scenePhase)
        private var status
    #endif

    var body: some View {
        #if os(macOS)
            let navigation = RegularNavigation()
        #else
            let navigation = DynamicNavigation()
        #endif

        navigation.environment(
            \.destinationCommands,
            status == .inactive ? .empty : destinationCommands
        )
    }
}

#Preview {
    MainView(destinationCommands: .empty)
}
