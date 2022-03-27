import UIKit

extension URL {
    init(for type: String, id: Data) {
        let host = Bundle.main.infoDictionary!["FPLinkHost"] as! String
        let encodedId = id.base64EncodedString().replacingOccurrences(of: "=", with: "")
        self.init(string: "https://\(host)/\(type)/\(encodedId)")!
    }

    func browse() {
        UIApplication.shared.open(self)
    }
}
