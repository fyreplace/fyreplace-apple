import Foundation

extension Data {
    var base64ShortString: String {
        return base64EncodedString().replacingOccurrences(of: "=", with: "")
    }

    init?(base64ShortString: String) {
        let paddedString = base64ShortString.padding(toLength: 24, withPad: "=", startingAt: 0)
        self.init(base64Encoded: paddedString)
    }
}
