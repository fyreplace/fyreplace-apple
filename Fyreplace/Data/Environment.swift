import SwiftUI

enum ServerEnvironment: String, CaseIterable, Identifiable {
    case main
    case dev
    #if DEBUG
        case local
    #endif

    var id: String { rawValue }

    var description: String {
        switch self {
        case .main:
            .init(localized: "Environment.Main")
        case .dev:
            .init(localized: "Environment.Dev")
        #if DEBUG
            case .local:
                .init(localized: "Environment.Local")
        #endif
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
