import Combine
import SwiftUI

struct DestinationCommands: Commands {
    var body: some Commands {
        CommandGroup(after: .sidebar) {
            Divider()

            ForEach(Destination.all) { destination in
                Button(destination.titleKey) {
                    DestinationCommandKey.subject.send(destination)
                }
                .keyboardShortcut(destination.keyboardShortcut)
            }

            Divider()
        }
    }
}

private struct DestinationCommandKey: EnvironmentKey {
    static let subject = PassthroughSubject<Destination, Never>()
    static let defaultValue = subject.eraseToAnyPublisher()
}

extension EnvironmentValues {
    var destinationCommands: AnyPublisher<Destination, Never> {
        get { self[DestinationCommandKey.self] }
        set { self[DestinationCommandKey.self] = newValue }
    }
}
