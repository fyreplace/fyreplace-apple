import UIKit

class TextPostTableViewCell: PostTableViewCell {
    @IBOutlet
    var preview: UILabel!

    override func setup(with chapter: FPChapter) {
        preview.text = chapter.text
        preview.font = chapter.preferredFont
    }
}
