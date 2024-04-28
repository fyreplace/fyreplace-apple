import UIKit

class LinkTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        delegate = self
    }
}

extension LinkTextView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let hostsString = Bundle.main.infoDictionary!["FPLinkHosts"] as! String
        let hosts: [String?] = hostsString.split(separator: ";").map { String($0) }
        guard (URL.scheme == "https" && hosts.contains(URL.host)) || URL.scheme == "fyreplace"
        else { return true }
        UIApplication.shared.open(url: URL)
        return false
    }
}
