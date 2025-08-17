import ReactiveCocoa
import SDWebImage
import UIKit

protocol ChapterTableViewCell {
    func setup(withChapter chapter: FPChapter)
}

class TextChapterTableViewCell: UITableViewCell {
    @IBOutlet
    var content: UILabel!
}

extension TextChapterTableViewCell: ChapterTableViewCell {
    func setup(withChapter chapter: FPChapter) {
        content.font = chapter.preferredFont
        content.textColor = chapter.text.isEmpty ? .placeholderText : .label
        content.text = chapter.text.isEmpty ? .tr("Draft.Empty") : chapter.text
    }
}

class ImageChapterTableViewCell: UITableViewCell {
    @IBOutlet
    var content: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        content.sd_imageIndicator = SDWebImageProgressIndicator.default
        content.sd_imageTransition = .fade
    }
}

extension ImageChapterTableViewCell: ChapterTableViewCell {
    func setup(withChapter chapter: FPChapter) {
        content.sd_setImage(with: .init(string: chapter.image.url))
    }
}
