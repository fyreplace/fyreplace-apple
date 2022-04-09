import UIKit

class CommentTableViewCell: ItemTableViewCell {
    @IBOutlet
    var content: UITextView!

    func setup(with comment: FPComment, isPostAuthor: Bool) {
        setup(at: comment.dateCreated.date, with: comment.author)
        username.textColor = isPostAuthor ? .init(named: "AccentColor") : .labelCompat
        content.text = comment.text
    }
}
