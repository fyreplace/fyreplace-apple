import SwiftUI

@available(macOS, unavailable)
struct CompactNavigation: View {
    @SceneStorage("CompactNavigation.selectedTab")
    private var selectedTab = Destination.feed

    @SceneStorage("CompactNavigation.notificationsChoice")
    private var notificationsChoice = Destination.notifications

    @SceneStorage("CompactNavigation.draftsChoice")
    private var draftsChoice = Destination.drafts

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                Screen(destination: .feed)
            }
            .tabItem { Label(.feed) }
            .tag(Destination.feed)

            NavigationStack {
                MultiChoiceScreen(
                    choices: [.notifications, .archive],
                    choice: $notificationsChoice
                )
            }
            .tabItem { Label(.notifications) }
            .tag(Destination.notifications)

            NavigationStack {
                MultiChoiceScreen(
                    choices: [.drafts, .published],
                    choice: $draftsChoice
                )
            }
            .tabItem { Label(.drafts) }
            .tag(Destination.drafts)

            NavigationStack {
                Screen(destination: .settings)
            }
            .tabItem { Label(.settings) }
            .tag(Destination.settings)
        }
    }
}

#if !os(macOS)
    #Preview {
        CompactNavigation()
    }
#endif
