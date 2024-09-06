import Foundation

extension String {
    static var randomUuid: String {
        UUID().uuidString
    }
}
