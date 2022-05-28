import Kingfisher
import ReactiveCocoa
import UIKit

protocol ChapterTableViewCell {
    func setup(with chapter: FPChapter)
}

class TextChapterTableViewCell: UITableViewCell {
    @IBOutlet
    var content: UILabel!
}

extension TextChapterTableViewCell: ChapterTableViewCell {
    func setup(with chapter: FPChapter) {
        content.font = chapter.preferredFont
        content.textColor = chapter.text.isEmpty ? .placeholderTextCompat : .labelCompat
        content.text = chapter.text.isEmpty ? .tr("Draft.Empty") : chapter.text
    }
}

class ImageChapterTableViewCell: UITableViewCell {
    @IBOutlet
    var content: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        content.kf.indicatorType = .activity
    }
}

extension ImageChapterTableViewCell: ChapterTableViewCell {
    func setup(with chapter: FPChapter) {
        content.kf.setImage(
            with: URL(string: chapter.image.url),
            options: [.transition(.fade(0.3))]
        )
    }
}
