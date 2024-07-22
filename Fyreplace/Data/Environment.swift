import SwiftUI

enum ServerEnvironment: String, CaseIterable, Identifiable {
    case main
    case dev
    case local

    var id: String { rawValue }

    var description: String {
        switch self {
        case .main:
            .init(localized: "Environment.Main")
        case .dev:
            .init(localized: "Environment.Dev")
        case .local:
            .init(localized: "Environment.Local")
        }
    }

    static var `default`: ServerEnvironment {
        #if DEBUG
            .local
        #else
            switch Config.default.version.environment {
            case "dev":
                .dev
            default:
                .main
            }
        #endif
    }
}
