import SwiftUI

@available(macOS, unavailable)
struct MultiChoiceScreen: View {
    let choices: [Destination]
    @Binding
    var choice: Destination

    var body: some View {
        ZStack {
            Screen(destination: choice)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("MultiChoiceScreen.Tab", selection: $choice) {
                    ForEach(choices) { choice in
                        Text(choice.titleKey).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .accessibilityIdentifier("tabs")
            }
        }
    }
}

#if DEBUG && !os(macOS)
    private enum PreviewData {
        @State
        static var choice = Destination.feed
    }

    #Preview {
        NavigationStack {
            MultiChoiceScreen(
                choices: [.feed, .settings],
                choice: PreviewData.$choice
            )
        }
    }
#endif
