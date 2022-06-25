import Kingfisher
import UIKit

class CommentTableViewCell: UITableViewCell {
    @IBOutlet
    var avatar: UIButton!
    @IBOutlet
    var username: UIButton!
    @IBOutlet
    var content: UITextView!
    @IBOutlet
    var date: UILabel?
    @IBOutlet
    var dateFormat: DateFormat?

    func setup(with comment: FPComment, isPostAuthor: Bool) {
        avatar?.setAvatar(comment.author.avatar.url)
        username?.tintColor = isPostAuthor ? .init(named: "AccentColor") : .labelCompat
        username?.setUsername(comment.author)
        content.text = comment.text
        date?.text = dateFormat?.string(from: comment.dateCreated.date)
    }
}
