import SwiftUI

struct CompactNavigation: View {
    @SceneStorage("CompactNavigation.selectedTab")
    private var selectedTab = Destination.feed

    @SceneStorage("CompactNavigation.choices")
    private var choices = Destination.all.filter { $0.parent == nil }

    var body: some View {
        TabView(selection: $selectedTab) {
            let destinations = Destination.all.filter { $0.parent == nil }

            ForEach(Array(destinations.enumerated()), id: \.element.id) { i, destination in
                NavigationStack {
                    let children = Destination.all.filter { $0.parent == destination }

                    if children.isEmpty {
                        Screen(destination: destination)
                    } else {
                        MultiChoiceScreen(
                            choices: [destination] + children,
                            choice: $choices[i]
                        )
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
