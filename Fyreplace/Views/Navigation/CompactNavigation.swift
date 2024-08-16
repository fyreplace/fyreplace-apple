import SwiftUI

struct CompactNavigation: View {
    @SceneStorage("CompactNavigation.selectedTab")
    private var selectedTab = Destination.feed

    @SceneStorage("CompactNavigation.selectedChoices")
    private var selectedChoices = Destination.essentials

    @KeychainStorage("connection.token")
    private var token

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Array(Destination.essentials.enumerated()), id: \.element.id) { i, destination in
                NavigationStack {
                    let content = CompactNavigationDestination(destination: destination, multiScreenChoice: $selectedChoices[i])

                    if destination.canOfferAuthentication {
                        AuthenticatingScreen { content }
                    } else {
                        content
                    }
                }
                .tabItem { Label(destination) }
                .tag(destination)
            }
        }
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
