import UIKit

extension URL {
    init(for type: String, id: Data, at position: Int? = nil) {
        let host = Bundle.main.infoDictionary!["FPLinkHost"] as! String
        var urlString = "https://\(host)/\(type)/\(id.base64ShortString)"

        if let position = position {
            urlString += "/\(position)"
        }

        self.init(string: urlString)!
    }

    func browse() {
        UIApplication.shared.open(self)
    }
}
