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
        guard (URL.scheme == "https" && URL.host == "fyreplace.link") || URL.scheme == "fyreplace"
        else { return true }
        UIApplication.shared.open(url: URL)
        return false
    }
}
