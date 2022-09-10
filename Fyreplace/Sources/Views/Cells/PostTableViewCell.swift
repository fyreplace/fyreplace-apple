import UIKit

protocol PostTableViewCell {
    func setup(withPost post: FPPost)

    func setup(withChapter chapter: FPChapter)
}

extension PostTableViewCell where Self: ItemTableViewCell {
    func setup(withPost post: FPPost) {
        setup(withProfile: post.author, at: post.dateCreated.date)
        guard let chapter = post.chapters.first else { return }
        setup(withChapter: chapter)
    }
}

class TextPostTableViewCell: TextItemTableViewCell, PostTableViewCell {
    func setup(withChapter chapter: FPChapter) {
        preview.font = chapter.preferredFont
        setup(withText: chapter.text)
    }
}

class ImagePostTableViewCell: ImageItemTableViewCell, PostTableViewCell {
    func setup(withChapter chapter: FPChapter) {
        setup(withUrl: URL(string: chapter.image.url))
    }
}
