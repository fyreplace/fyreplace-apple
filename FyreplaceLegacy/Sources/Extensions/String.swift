import Foundation

extension String {
    static func tr(_ key: String) -> String {
        return .init(localized: .init(stringLiteral: key), table: "Legacy")
    }

    var pascalized: String {
        return split(separator: "_").map { $0.capitalized }.joined()
    }
}
