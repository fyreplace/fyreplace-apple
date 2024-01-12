import GRPC
import SwiftProtobuf

func makeInterceptors<Request, Response>() -> [ClientInterceptor<Request, Response>] {
    return [RequestIdentificationInterceptor(), AuthenticationInterceptor()]
}

struct AccountServiceClientInterceptorFactory: FPAccountServiceClientInterceptorFactoryProtocol {
    func makeCreateInterceptors() -> [ClientInterceptor<FPUserCreation, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeSendActivationEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeConfirmActivationInterceptors() -> [ClientInterceptor<FPConnectionToken, FPToken>] {
        return makeInterceptors()
    }

    func makeListConnectionsInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPConnections>] {
        return makeInterceptors()
    }

    func makeSendConnectionEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeConfirmConnectionInterceptors() -> [ClientInterceptor<FPConnectionToken, FPToken>] {
        return makeInterceptors()
    }

    func makeConnectInterceptors() -> [ClientInterceptor<FPConnectionCredentials, FPToken>] {
        return makeInterceptors()
    }

    func makeDisconnectInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeDisconnectAllInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}

struct UserServiceClientInterceptorFactory: FPUserServiceClientInterceptorFactoryProtocol {
    func makeRetrieveInterceptors() -> [ClientInterceptor<FPId, FPUser>] {
        return makeInterceptors()
    }

    func makeRetrieveMeInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPUser>] {
        return makeInterceptors()
    }

    func makeUpdateAvatarInterceptors() -> [ClientInterceptor<FPImageChunk, FPImage>] {
        return makeInterceptors()
    }

    func makeUpdateBioInterceptors() -> [ClientInterceptor<FPBio, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeSendEmailUpdateEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeConfirmEmailUpdateInterceptors() -> [ClientInterceptor<FPToken, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeListBlockedInterceptors() -> [ClientInterceptor<FPPage, FPProfiles>] {
        return makeInterceptors()
    }

    func makeUpdateBlockInterceptors() -> [ClientInterceptor<FPBlock, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeBanInterceptors() -> [ClientInterceptor<FPBanSentence, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makePromoteInterceptors() -> [ClientInterceptor<FPPromotion, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}

struct PostServiceClientInterceptorFactory: FPPostServiceClientInterceptorFactoryProtocol {
    func makeListFeedInterceptors() -> [ClientInterceptor<FPVote, FPPost>] {
        return makeInterceptors()
    }

    func makeListArchiveInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return makeInterceptors()
    }

    func makeListOwnPostsInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return makeInterceptors()
    }

    func makeListDraftsInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return makeInterceptors()
    }

    func makeRetrieveInterceptors() -> [ClientInterceptor<FPId, FPPost>] {
        return makeInterceptors()
    }

    func makeCreateInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPId>] {
        return makeInterceptors()
    }

    func makePublishInterceptors() -> [ClientInterceptor<FPPublication, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeUpdateSubscriptionInterceptors() -> [ClientInterceptor<FPSubscription, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}

struct ChapterServiceClientInterceptorFactory: FPChapterServiceClientInterceptorFactoryProtocol {
    func makeCreateInterceptors() -> [ClientInterceptor<FPChapterLocation, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeMoveInterceptors() -> [ClientInterceptor<FPChapterRelocation, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeUpdateTextInterceptors() -> [ClientInterceptor<FPChapterTextUpdate, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeUpdateImageInterceptors() -> [ClientInterceptor<FPChapterImageUpdate, FPImage>] {
        return makeInterceptors()
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPChapterLocation, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}

struct CommentServiceClientInterceptorFactory: FPCommentServiceClientInterceptorFactoryProtocol {
    func makeListInterceptors() -> [ClientInterceptor<FPPage, FPComments>] {
        return makeInterceptors()
    }

    func makeCreateInterceptors() -> [ClientInterceptor<FPCommentCreation, FPId>] {
        return makeInterceptors()
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeAcknowledgeInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}

struct NotificationServiceClientInterceptorFactory: FPNotificationServiceClientInterceptorFactoryProtocol {
    func makeCountInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPNotificationCount>] {
        return makeInterceptors()
    }

    func makeListInterceptors() -> [ClientInterceptor<FPPage, FPNotifications>] {
        return makeInterceptors()
    }

    func makeClearInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }

    func makeRegisterTokenInterceptors() -> [ClientInterceptor<FPMessagingToken, Google_Protobuf_Empty>] {
        return makeInterceptors()
    }
}
