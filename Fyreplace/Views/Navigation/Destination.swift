import SwiftUI

enum Destination: String, CaseIterable, Identifiable {
    case feed
    case notifications
    case archive
    case drafts
    case published
    case settings

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .feed:
            "Main.Feed"
        case .notifications:
            "Main.Notifications"
        case .archive:
            "Main.Archive"
        case .drafts:
            "Main.Drafts"
        case .published:
            "Main.Published"
        case .settings:
            "Main.Settings"
        }
    }

    var icon: String {
        switch self {
        case .feed:
            "house.fill"
        case .notifications:
            "bell.fill"
        case .archive:
            "bookmark.fill"
        case .drafts:
            "doc.text.fill"
        case .published:
            "archivebox.fill"
        case .settings:
            "person.crop.circle.fill"
        }
    }
}
