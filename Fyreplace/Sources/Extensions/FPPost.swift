extension FPPost {
    func makePreview(anonymous: Bool = false) -> FPPost {
        var post = self
        post.isPreview = true

        if anonymous {
            post.clearAuthor()
        }

        if let chapter = post.chapters.first {
            post.chapters = [chapter]
        } else {
            post.chapters = []
        }

        return post
    }
}
