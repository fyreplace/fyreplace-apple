import Foundation

extension String {
    static func tr(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }

    var pascalized: String {
        return split(separator: "_").map { $0.capitalized }.joined()
    }
}
