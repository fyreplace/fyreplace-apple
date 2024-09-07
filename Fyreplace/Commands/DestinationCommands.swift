import SwiftUI

struct DestinationCommands: Commands {
    let eventBus: EventBus

    var body: some Commands {
        CommandGroup(after: .sidebar) {
            DestinationCommandsContent(eventBus: eventBus)
        }
    }
}

struct DestinationCommandsContent: View {
    let eventBus: EventBus

    @KeychainStorage("connection.token")
    private var token

    var body: some View {
        Divider()

        ForEach(Destination.all) { destination in
            Button(destination.titleKey) {
                Task {
                    eventBus.send(.navigationShortcut(to: destination))
                }
            }
            .disabled(destination.requiresAuthentication && token.isEmpty)
            .keyboardShortcut(destination.keyboardShortcut)
        }

        Divider()
    }
}
