import LinkPresentation

class PostActivityItemProvider: URLActivityItemProvider {
    private let post: FPPost

    init(post: FPPost) {
        self.post = post
        super.init(url: .init(for: "p", id: post.id))
    }

    @available(iOS 13.0, *)
    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = super.activityViewControllerLinkMetadata(activityViewController)
        let author = post.author.getNormalizedUsername(with: nil).string
        metadata?.title = .localizedStringWithFormat(.tr("Post.Share.Title"), author)
        return metadata
    }
}
