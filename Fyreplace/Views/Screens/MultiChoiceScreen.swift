import SwiftUI

struct MultiChoiceScreen: View {
    let choices: [Destination]

    @Binding
    var choice: Destination

    var body: some View {
        ZStack {
            Screen(destination: choice)
        }
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
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

#if DEBUG
    struct Preview: View {
        @State
        var choice = Destination.feed

        var body: some View {
            NavigationStack {
                MultiChoiceScreen(
                    choices: [.feed, .settings],
                    choice: $choice
                )
            }
        }
    }

    #Preview {
        Preview()
    }
#endif
