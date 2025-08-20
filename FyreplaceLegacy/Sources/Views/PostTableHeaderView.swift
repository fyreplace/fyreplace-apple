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
            let chapterView = chapter.toView()
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
}
