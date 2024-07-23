import SwiftUI

struct Screen: View {
    let destination: Destination

    @Namespace
    private var namespace

    var body: some View {
        switch destination {
        case .feed:
            FeedScreen()
        case .notifications:
            NotificationsScreen()
        case .archive:
            ArchiveScreen()
        case .drafts:
            DraftsScreen()
        case .published:
            PublishedScreen()
        case .settings:
            SettingsScreen()
        case .login:
            LoginScreen(namespace: namespace)
        case .register:
            RegisterScreen(namespace: namespace)
        }
    }
}
