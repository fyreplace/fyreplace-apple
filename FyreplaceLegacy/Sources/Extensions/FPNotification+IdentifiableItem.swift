import Foundation

extension FPNotification: IdentifiableItem {
    var id: Data {
        var data: Data

        switch target {
        case .user(user):
            data = user.id

        case .post(post):
            data = post.id

        case .comment(comment):
            data = comment.id

        default:
            data = .init()
        }

        data.append(isFlag ? 1 : 0)
        return data
    }
}
