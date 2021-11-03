import UIKit
import SDWebImage

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
        var theFrame = self.frame

        if theFrame.height != height {
            theFrame.size.height = height
            self.frame = theFrame
        }
    }

    private func makeView(from chapter: FPChapter) -> UIView {
        return chapter.hasImage ? makeImageView(from: chapter) : makeLabel(from: chapter)
    }

    private func makeLabel(from chapter: FPChapter) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = chapter.text
        label.font = chapter.preferredFont
        container.addSubview(label)
        label.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20).isActive = true
        return container
    }

    private func makeImageView(from chapter: FPChapter) -> UIView {
        let ratio = CGFloat(chapter.image.height) / CGFloat(chapter.image.width)
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.sd_imageTransition = .fade
        imageView.sd_imageIndicator = SDWebImageProgressIndicator.default
        imageView.sd_setImage(with: URL(string: chapter.image.url))
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio).isActive = true
        return imageView
    }
}

struct InvalidChapterViewError: Error {}
