import Foundation
import OpenAPIRuntime

struct FakeClient: APIProtocol {}

extension APIProtocol {
    typealias fake = FakeClient
}

// MARK: Chapters

extension FakeClient {
    func createChapter(_: Operations.createChapter.Input) async throws
        -> Operations.createChapter.Output
    {
        fatalError("Not implemented")
    }

    func deleteChapter(_: Operations.deleteChapter.Input) async throws
        -> Operations.deleteChapter.Output
    {
        fatalError("Not implemented")
    }

    func setChapterImage(_: Operations.setChapterImage.Input) async throws
        -> Operations.setChapterImage.Output
    {
        fatalError("Not implemented")
    }

    func setChapterPosition(_: Operations.setChapterPosition.Input) async throws
        -> Operations.setChapterPosition.Output
    {
        fatalError("Not implemented")
    }

    func setChapterText(_: Operations.setChapterText.Input) async throws
        -> Operations.setChapterText.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Comments

extension FakeClient {
    func acknowledgeComment(_: Operations.acknowledgeComment.Input) async throws
        -> Operations.acknowledgeComment.Output
    {
        fatalError("Not implemented")
    }

    func countComments(_: Operations.countComments.Input) async throws
        -> Operations.countComments.Output
    {
        fatalError("Not implemented")
    }

    func createComment(_: Operations.createComment.Input) async throws
        -> Operations.createComment.Output
    {
        fatalError("Not implemented")
    }

    func deleteComment(_: Operations.deleteComment.Input) async throws
        -> Operations.deleteComment.Output
    {
        fatalError("Not implemented")
    }

    func listComments(_: Operations.listComments.Input) async throws
        -> Operations.listComments.Output
    {
        fatalError("Not implemented")
    }

    func setCommentReported(_: Operations.setCommentReported.Input) async throws
        -> Operations.setCommentReported.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Emails

extension FakeClient {
    func activateEmail(_: Operations.activateEmail.Input) async throws
        -> Operations.activateEmail.Output
    {
        fatalError("Not implemented")
    }

    func countEmails(_: Operations.countEmails.Input) async throws
        -> Operations.countEmails.Output
    {
        let emails = try await listEmails(.init()).ok.body.json
        return .ok(.init(body: .json(Int64(emails.count))))
    }

    func createEmail(_: Operations.createEmail.Input) async throws
        -> Operations.createEmail.Output
    {
        fatalError("Not implemented")
    }

    func deleteEmail(_: Operations.deleteEmail.Input) async throws
        -> Operations.deleteEmail.Output
    {
        fatalError("Not implemented")
    }

    func listEmails(_ input: Operations.listEmails.Input) async throws
        -> Operations.listEmails.Output
    {
        return switch input.query.page {
        case nil, 0:
            .ok(.init(body: .json([.make(main: true), .make(), .make()])))

        default:
            .ok(.init(body: .json([])))
        }
    }

    func setMainEmail(_: Operations.setMainEmail.Input) async throws
        -> Operations.setMainEmail.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Posts

extension FakeClient {
    func countPosts(_: Operations.countPosts.Input) async throws
        -> Operations.countPosts.Output
    {
        fatalError("Not implemented")
    }

    func createPost(_: Operations.createPost.Input) async throws
        -> Operations.createPost.Output
    {
        fatalError("Not implemented")
    }

    func deletePost(_: Operations.deletePost.Input) async throws
        -> Operations.deletePost.Output
    {
        fatalError("Not implemented")
    }

    func getPost(_: Operations.getPost.Input) async throws
        -> Operations.getPost.Output
    {
        fatalError("Not implemented")
    }

    func listPosts(_: Operations.listPosts.Input) async throws
        -> Operations.listPosts.Output
    {
        fatalError("Not implemented")
    }

    func listPostsFeed(_: Operations.listPostsFeed.Input) async throws
        -> Operations.listPostsFeed.Output
    {
        fatalError("Not implemented")
    }

    func publishPost(_: Operations.publishPost.Input) async throws
        -> Operations.publishPost.Output
    {
        fatalError("Not implemented")
    }

    func setPostReported(_: Operations.setPostReported.Input) async throws
        -> Operations.setPostReported.Output
    {
        fatalError("Not implemented")
    }

    func setPostSubscribed(_: Operations.setPostSubscribed.Input) async throws
        -> Operations.setPostSubscribed.Output
    {
        fatalError("Not implemented")
    }

    func votePost(_: Operations.votePost.Input) async throws
        -> Operations.votePost.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Reports

extension FakeClient {
    func listReports(_: Operations.listReports.Input) async throws
        -> Operations.listReports.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Subscriptions

extension FakeClient {
    func clearUnreadSubscriptions(_: Operations.clearUnreadSubscriptions.Input) async throws
        -> Operations.clearUnreadSubscriptions.Output
    {
        fatalError("Not implemented")
    }

    func deleteSubscription(_: Operations.deleteSubscription.Input) async throws
        -> Operations.deleteSubscription.Output
    {
        fatalError("Not implemented")
    }

    func listUnreadSubscriptions(_: Operations.listUnreadSubscriptions.Input) async throws
        -> Operations.listUnreadSubscriptions.Output
    {
        fatalError("Not implemented")
    }
}

// MARK: Tokens

extension FakeClient {
    static let goodIdentifers = [goodUsername, goodEmail]
    static let badSecret = "nopenope"
    static let goodSecret = "abcd1234"
    static let badToken = "bad-token"
    static let goodToken = "good-token"

    func createNewToken(_ input: Operations.createNewToken.Input) async throws
        -> Operations.createNewToken.Output
    {
        return switch input.body {
        case let .json(json) where Self.goodIdentifers.contains(json.identifier):
            .ok(.init())

        case let .json(json) where json.identifier == Self.passwordUsername:
            .forbidden(.init(body: .json(.init())))

        case .json:
            .notFound(.init())
        }
    }

    func createToken(_ input: Operations.createToken.Input) async throws
        -> Operations.createToken.Output
    {
        return switch input.body {
        case let .json(json)
        where Self.goodIdentifers.contains(json.identifier) && json.secret == Self.goodSecret:
            .created(.init(body: .plainText(.init(stringLiteral: Self.goodToken))))

        case .json:
            .notFound(.init())
        }
    }

    func getNewToken(_: Operations.getNewToken.Input) async throws
        -> Operations.getNewToken.Output
    {
        return .ok(.init(body: .plainText(.init(stringLiteral: Self.goodToken))))
    }
}

// MARK: Users

extension FakeClient {
    static let badUsername = "bad-username"
    static let reservedUsername = "reserved-username"
    static let usedUsername = "used-username"
    static let passwordUsername = "password-username"
    static let goodUsername = "good-username"

    static let badEmail = "bad@email"
    static let usedEmail = "used@email"
    static let goodEmail = "good@email"

    static let notImageBody = HTTPBody(stringLiteral: "Not")
    static let largeImageBody = HTTPBody(stringLiteral: "Large")
    static let normalImageBody = HTTPBody(stringLiteral: "Normal")

    static let avatar = "avatar"

    func countBlockedUsers(_: Operations.countBlockedUsers.Input) async throws
        -> Operations.countBlockedUsers.Output
    {
        fatalError("Not implemented")
    }

    func createUser(_ input: Operations.createUser.Input) async throws
        -> Operations.createUser.Output
    {
        return switch input.body {
        case let .json(json) where json.username == Self.badUsername:
            .badRequest(.init(body: .json(.init())))

        case let .json(json) where json.username == Self.reservedUsername:
            .forbidden(.init(body: .json(.init())))

        case let .json(json) where json.username == Self.usedUsername:
            .conflict(.init(body: .json(.init())))

        case let .json(json) where json.username == Self.passwordUsername:
            .forbidden(.init(body: .json(.init())))

        case let .json(json) where json.email == Self.badEmail:
            .badRequest(.init(body: .json(.init())))

        case let .json(json) where json.email == Self.usedEmail:
            .conflict(.init(body: .json(.init())))

        case let .json(json):
            .created(.init(body: .json(.make(named: json.username))))
        }
    }

    func deleteCurrentUser(_: Operations.deleteCurrentUser.Input) async throws
        -> Operations.deleteCurrentUser.Output
    {
        fatalError("Not implemented")
    }

    func deleteCurrentUserAvatar(_: Operations.deleteCurrentUserAvatar.Input) async throws
        -> Operations.deleteCurrentUserAvatar.Output
    {
        return .noContent(.init())
    }

    func getCurrentUser(_: Operations.getCurrentUser.Input) async throws
        -> Operations.getCurrentUser.Output
    {
        return .ok(.init(body: .json(.placeholder)))
    }

    func getUser(_: Operations.getUser.Input) async throws
        -> Operations.getUser.Output
    {
        fatalError("Not implemented")
    }

    func listBlockedUsers(_: Operations.listBlockedUsers.Input) async throws
        -> Operations.listBlockedUsers.Output
    {
        fatalError("Not implemented")
    }

    func setCurrentUserAvatar(_ input: Operations.setCurrentUserAvatar.Input) async throws
        -> Operations.setCurrentUserAvatar.Output
    {
        let normalImage = try await String(collecting: Self.normalImageBody, upTo: 64)
        let largeImage = try await String(collecting: Self.largeImageBody, upTo: 64)

        return switch input.body {
        case let .binary(binary) where try await String(collecting: binary, upTo: 64) == normalImage:
            .ok(.init(body: .plainText(.init(stringLiteral: Self.avatar))))

        case let .binary(binary) where try await String(collecting: binary, upTo: 64) == largeImage:
            .contentTooLarge(.init())

        case .binary:
            .unsupportedMediaType(.init())
        }
    }

    func setCurrentUserBio(_ input: Operations.setCurrentUserBio.Input) async throws
        -> Operations.setCurrentUserBio.Output
    {
        return switch input.body {
        case let .plainText(text):
            .ok(.init(body: .plainText(text)))
        }
    }

    func setUserBanned(_: Operations.setUserBanned.Input) async throws
        -> Operations.setUserBanned.Output
    {
        fatalError("Not implemented")
    }

    func setUserBlocked(_: Operations.setUserBlocked.Input) async throws
        -> Operations.setUserBlocked.Output
    {
        fatalError("Not implemented")
    }

    func setUserReported(_: Operations.setUserReported.Input) async throws
        -> Operations.setUserReported.Output
    {
        fatalError("Not implemented")
    }
}
