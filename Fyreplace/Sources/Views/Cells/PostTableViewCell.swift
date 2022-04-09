class PostTableViewCell: ItemTableViewCell {
    func setup(with post: FPPost) {
        setup(at: post.dateCreated.date, with: post.author)
        guard let chapter = post.chapters.first else { return }
        setup(with: chapter)
    }

    func setup(with chapter: FPChapter) {}
}
