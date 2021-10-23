import UIKit

class DateFormat: DateFormatter {
    @IBInspectable
    var concise: Bool = false { didSet { setupStyle() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }

    private func setupStyle() {
        dateStyle = concise ? .short : .medium
        timeStyle = concise ? .short : .medium
    }
}
