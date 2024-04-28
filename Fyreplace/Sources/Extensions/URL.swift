import UIKit

extension URL {
    init(for type: String, id: Data, at position: Int? = nil) {
        let hostsString = Bundle.main.infoDictionary!["FPLinkHosts"] as! String
        let host = hostsString.split(separator: ";").first!
        var urlString = "https://\(host)/\(type)/\(id.base64ShortString)"

        if let position {
            urlString += "/\(position)"
        }

        self.init(string: urlString)!
    }

    func browse() {
        UIApplication.shared.open(self)
    }
}
