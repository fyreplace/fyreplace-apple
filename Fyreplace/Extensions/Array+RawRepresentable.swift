import Foundation

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        self.init()
        guard let data = rawValue.data(using: .utf8),
            let result = try? JSONDecoder().decode([Element].self, from: data)
        else { return nil }
        result.forEach { append($0) }
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
            let value = String(data: data, encoding: .utf8)
        else { return "[]" }
        return value
    }
}
