import Foundation

extension Data {
    var base64ShortString: String {
        return base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    init?(base64ShortString: String) {
        let paddedString = base64ShortString
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
            .padding(toLength: 24, withPad: "=", startingAt: 0)
        self.init(base64Encoded: paddedString)
    }

    init(jsonObject: Any) throws {
        try self.init(referencing: .init(data: JSONSerialization.data(withJSONObject: jsonObject)))
    }
}
