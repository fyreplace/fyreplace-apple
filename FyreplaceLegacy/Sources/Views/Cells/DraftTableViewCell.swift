import UIKit

protocol DraftTableViewCell: PostTableViewCell {
    var parts: UILabel! { get }

    func setup(withDraft post: FPPost)
}

extension DraftTableViewCell {
    func setup(withDraft post: FPPost) {
        setup(withPost: post)
        parts.text = .localizedStringWithFormat(.tr("Drafts.Parts"), post.chapterCount)
    }
}

class TextDraftTableViewCell: TextPostTableViewCell, DraftTableViewCell {
    @IBOutlet
    var parts: UILabel!
}

class ImageDraftTableViewCell: ImagePostTableViewCell, DraftTableViewCell {
    @IBOutlet
    var parts: UILabel!
}
