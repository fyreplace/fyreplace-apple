import UIKit

extension URL {
    init(for type: String, id: Data) {
        let host = Bundle.main.infoDictionary!["FPLinkHost"] as! String
        self.init(string: "https://\(host)/\(type)/\(id.base64ShortString)")!
    }

    func browse() {
        UIApplication.shared.open(self)
    }
}
