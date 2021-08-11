import Foundation

public extension String {
    static func tr(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    var pascalized: String {
        return split(separator: "_").map { $0.capitalized }.joined()
    }
}
