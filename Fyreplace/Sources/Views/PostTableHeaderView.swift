import Kingfisher
import UIKit

class PostTableHeaderView: UIView {
    @IBOutlet
    var content: UIStackView!
    @IBOutlet
    var bottom: NSLayoutConstraint!

    func setup(with post: FPPost) {
        for view in content.arrangedSubviews {
            view.removeFromSuperview()
        }

        for chapter in post.chapters {
            let chapterView = makeView(from: chapter)
            chapterView.translatesAutoresizingMaskIntoConstraints = false
            content.addArrangedSubview(chapterView)
        }
    }

    func resize() {
        let height = content.bounds.height + 2 * abs(bottom.constant)
        var theFrame = frame

        if theFrame.height != height {
            theFrame.size.height = height
            frame = theFrame
        }
    }

    private func makeView(from chapter: FPChapter) -> UIView {
        return chapter.hasImage ? makeImage(from: chapter) : makeText(from: chapter)
    }

    private func makeText(from chapter: FPChapter) -> UIView {
        let container = UIView()
        let text = CompactTextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textAlignment = .center
        text.text = chapter.text
        text.font = chapter.preferredFont
        text.isScrollEnabled = false
        text.isEditable = false
        text.isSelectable = true
        container.addSubview(text)
        text.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        text.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        text.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        text.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
        return container
    }

    private func makeImage(from chapter: FPChapter) -> UIView {
        let ratio = CGFloat(chapter.image.height) / CGFloat(chapter.image.width)
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.kf.indicatorType = .activity
        image.kf.setImage(
            with: URL(string: chapter.image.url),
            options: [.transition(.fade(0.3))]
        )
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: ratio).isActive = true
        return image
    }
}

struct InvalidChapterViewError: Error {}
