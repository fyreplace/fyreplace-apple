import UIKit

@IBDesignable
class BaseCommentTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    func setupView() {
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 90).isActive = true
    }
}

@IBDesignable
class CommentTableViewCell: BaseCommentTableViewCell {
    @IBOutlet
    weak var delegate: CommentTableViewCellDelegate?
    @IBOutlet
    var highlight: UIView!
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
        avatar.sd_imageTransition = .fade
        originalFont = content.font
    }

    @IBAction
    func onUserViewPressed(_ view: UIView) {
        delegate?.commentTableViewCell(self, didClickOnView: view)
    }

    func setup(withComment comment: FPComment, at position: Int, isPostAuthor: Bool, isSelected: Bool, isHighlighted: Bool) {
        backgroundColor = isSelected ? .tintColor.withAlphaComponent(0.3) : nil
        highlight.isHidden = !isHighlighted
        avatar.isUserInteractionEnabled = !comment.author.username.isEmpty
        avatar.setAvatar(from: comment.author)
        avatar.tag = position
        username.isUserInteractionEnabled = avatar.isUserInteractionEnabled
        username.tintColor = isPostAuthor ? .tintColor : .label
        username.setUsername(comment.author)
        username.tag = position
        content.setComment(comment, font: isHighlighted ? originalFont?.withTraits(.traitBold) : originalFont)
        date.text = dateFormat.string(from: comment.dateCreated.date)
    }
}

@objc
protocol CommentTableViewCellDelegate: NSObjectProtocol {
    func commentTableViewCell(_ cell: CommentTableViewCell, didClickOnView view: UIView)
}
