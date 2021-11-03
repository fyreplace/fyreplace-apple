import Foundation
import SDWebImage

protocol PostTableViewCell {
    func setup(with post: FPPost)

    func setup(with chapter: FPChapter)
}

extension PostTableViewCell where Self: ItemTableViewCell {
    func setup(with post: FPPost) {
        setup(at: post.dateCreated.date, from: post.author)
        guard let chapter = post.chapters.first else { return }
        setup(with: chapter)
    }
}

extension TextItemTableViewCell: PostTableViewCell {
    func setup(with chapter: FPChapter) {
        preview.text = chapter.text
        preview.font = chapter.preferredFont
    }
}

extension ImageItemTableViewCell: PostTableViewCell {
    func setup(with chapter: FPChapter) {
        preview.sd_setImage(with: URL(string: chapter.image.url))
    }
}
