import SwiftUI

struct CompactNavigation: View, NavigationProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @SceneStorage("CompactNavigation.selectedDestination")
    private var selectedDestination = Destination.feed

    @SceneStorage("CompactNavigation.selectedChoices")
    private var selectedChoices = Destination.essentials

    @AppStorage("account.isRegistering")
    private var isRegistering = false

    var body: some View {
        TabView(selection: $selectedDestination) {
            ForEach(Array(Destination.essentials.enumerated()), id: \.element.id) {
                i, destination in
                NavigationStack {
                    let content = CompactNavigationDestination(
                        destination: destination,
                        multiScreenChoice: $selectedChoices[i]
                    )

                    if destination.canOfferAuthentication {
                        AuthenticatingScreen(isRegistering: isRegistering) { content }
                    } else {
                        content
                    }
                }
                .tabItem { Label(destination) }
                .tag(destination)
            }
        }
        .onDeepLink(perform: handle)
    }

    func navigateToSettings() {
        selectedDestination = .settings
    }
}

#Preview {
    CompactNavigation()
}

private struct CompactNavigationDestination: View {
    let destination: Destination

    let multiScreenChoice: Binding<Destination>

    var body: some View {
        let children = Destination.all.filter { $0.parent == destination }

        if children.isEmpty {
            Screen(destination: destination)
        } else {
            MultiChoiceScreen(
                choices: [destination] + children,
                choice: multiScreenChoice
            )
        }
    }
}
