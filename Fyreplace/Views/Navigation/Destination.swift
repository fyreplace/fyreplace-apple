import SwiftUI

public enum Destination: String, Codable, Identifiable {
    case feed
    case notifications
    case archive
    case drafts
    case published
    case settings
    case login
    case register

    public var id: String {
        .init(reflecting: self)
    }

    var parent: Destination? {
        switch self {
        case .archive:
            .notifications
        case .published:
            .drafts
        default:
            nil
        }
    }

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
        case .login:
            "Main.Login"
        case .register:
            "Main.Register"
        }
    }

    var icon: String {
        switch self {
        case .feed:
            "house"
        case .notifications:
            "bell"
        case .archive:
            "bookmark"
        case .drafts:
            "doc.text"
        case .published:
            "archivebox"
        case .settings:
            "person.crop.circle"
        case .login, .register:
            ""
        }
    }

    var canOfferAuthentication: Bool {
        switch self {
        case .feed,
             .login,
             .register:
            false
        default:
            true
        }
    }

    var requiresAuthentication: Bool {
        switch self {
        case .feed,
             .settings,
             .login,
             .register:
            false
        default:
            true
        }
    }

    var keyboardShortcut: KeyboardShortcut? {
        switch self {
        case .feed:
            .init("1")
        case .notifications:
            .init("2")
        case .archive:
            .init("3")
        case .drafts:
            .init("4")
        case .published:
            .init("5")
        case .settings:
            .init("6")
        case .login, .register:
            nil
        }
    }

    static let all: [Destination] = [
        .feed,
        .notifications,
        .archive,
        .drafts,
        .published,
        .settings,
    ]

    static let essentials = all.filter { $0.parent == nil }
}
