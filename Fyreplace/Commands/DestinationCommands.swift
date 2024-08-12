import SwiftUI

struct DestinationCommands: Commands {
    let eventBus: EventBus

    var body: some Commands {
        CommandGroup(after: .sidebar) {
            Divider()

            ForEach(Destination.all) { destination in
                Button(destination.titleKey) {
                    Task {
                        await eventBus.send(.navigationShortcut(to: destination))
                    }
                }
                .keyboardShortcut(destination.keyboardShortcut)
            }

            Divider()
        }
    }
}
