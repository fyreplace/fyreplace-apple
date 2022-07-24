import Kingfisher
import UIKit

@IBDesignable
class CommentTableViewCell: BaseCommentTableViewCell {
    @IBOutlet
    var avatar: UIButton!
    @IBOutlet
    var username: UIButton!
    @IBOutlet
    var content: UITextView!
    @IBOutlet
    var date: UILabel!
    @IBOutlet
    var dateFormat: DateFormat!

    private var originalFont: UIFont?

    override func awakeFromNib() {
        super.awakeFromNib()
        originalFont = content.font
    }

    func setup(with comment: FPComment, at position: Int, isPostAuthor: Bool, isSelected: Bool) {
        backgroundColor = isSelected ? .accent.withAlphaComponent(0.3) : nil
        avatar.setAvatar(from: comment.author)
        avatar.tag = position
        username.tintColor = isPostAuthor ? .accent : .labelCompat
        username.setUsername(comment.author)
        username.tag = position
        content.setComment(comment, font: originalFont)
        date.text = dateFormat.string(from: comment.dateCreated.date)
    }
}
