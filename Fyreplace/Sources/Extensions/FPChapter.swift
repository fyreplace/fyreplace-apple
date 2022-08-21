import Kingfisher
import UIKit

extension FPChapter {
    var preferredFont: UIFont { .preferredFont(forTextStyle: isTitle ? .title1 : .body) }

    func toView() -> UIView {
        let view = hasImage ? toImage() : toText()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    func toText() -> UIView {
        let container = UIView()
        let text = CompactTextView()
        text.setup()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = preferredFont
        text.text = self.text
        text.isScrollEnabled = false
        text.isEditable = false
        text.isSelectable = true
        text.dataDetectorTypes = [.phoneNumber, .link, .address, .calendarEvent, .lookupSuggestion]
        container.addSubview(text)
        text.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        text.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        text.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
        return container
    }

    func toImage() -> UIView {
        let ratio = CGFloat(image.height) / CGFloat(image.width)
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.kf.indicatorType = .activity
        image.kf.setImage(
            with: URL(string: self.image.url),
            options: [.transition(.fade(0.3))]
        )
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: ratio).isActive = true
        return image
    }
}
