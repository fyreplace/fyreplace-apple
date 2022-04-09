import UIKit

class TextDraftTableViewCell: TextPostTableViewCell {
    @IBOutlet
    var parts: UILabel!

    override func setup(with post: FPPost) {
        super.setup(with: post)
        parts.text = .localizedStringWithFormat(.tr("Drafts.Parts"), post.chapters.count)
    }
}
