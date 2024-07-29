import Combine
import SwiftUI

struct DestinationCommands: Commands {
    var subject: PassthroughSubject<Destination, Never>

    var body: some Commands {
        CommandGroup(after: .sidebar) {
            Divider()

            ForEach(Destination.all) { destination in
                Button(destination.titleKey) {
                    subject.send(destination)
                }
                .keyboardShortcut(destination.keyboardShortcut)
            }

            Divider()
        }
    }
}

struct DestinationCommandEnvironmentKey: EnvironmentKey {
    static let defaultValue = AnyPublisher<Destination, Never>.empty
}

extension EnvironmentValues {
    var destinationCommands: AnyPublisher<Destination, Never> {
        get { self[DestinationCommandEnvironmentKey.self] }
        set { self[DestinationCommandEnvironmentKey.self] = newValue }
    }
}
