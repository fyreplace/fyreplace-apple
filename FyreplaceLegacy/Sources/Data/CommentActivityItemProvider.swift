import LinkPresentation

class CommentActivityItemProvider: URLActivityItemProvider, @unchecked Sendable {
    private let comment: FPComment

    init(post: FPPost, comment: FPComment, at position: Int) {
        self.comment = comment
        super.init(url: .init(for: "p", id: post.id, at: position))
    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = super.activityViewControllerLinkMetadata(activityViewController)
        let author = comment.author.getNormalizedUsername(with: nil).string
        metadata?.title = .localizedStringWithFormat(.tr("Post.Comment.Share.Title"), author)
        return metadata
    }
}
