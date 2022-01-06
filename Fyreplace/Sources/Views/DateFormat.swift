import UIKit

class DateFormat: DateFormatter {
    @IBInspectable
    var concise: Bool = false { didSet { setupStyle() } }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()

        if let lang = Bundle.main.localizations.first {
            locale = .init(identifier: lang)
        }
    }

    private func setupStyle() {
        dateStyle = concise ? .short : .medium
        timeStyle = concise ? .short : .medium
    }
}
