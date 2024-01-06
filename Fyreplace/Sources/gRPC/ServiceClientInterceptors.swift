import GRPC
import SwiftProtobuf

struct AccountServiceClientInterceptorFactory: FPAccountServiceClientInterceptorFactoryProtocol {
    func makeCreateInterceptors() -> [ClientInterceptor<FPUserCreation, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPUserCreation, Google_Protobuf_Empty>()]
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>()]
    }

    func makeSendActivationEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPEmail, Google_Protobuf_Empty>()]
    }

    func makeConfirmActivationInterceptors() -> [ClientInterceptor<FPConnectionToken, FPToken>] {
        return [AuthenticationInterceptor<FPConnectionToken, FPToken>()]
    }

    func makeListConnectionsInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPConnections>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, FPConnections>()]
    }

    func makeSendConnectionEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPEmail, Google_Protobuf_Empty>()]
    }

    func makeConfirmConnectionInterceptors() -> [ClientInterceptor<FPConnectionToken, FPToken>] {
        return [AuthenticationInterceptor<FPConnectionToken, FPToken>()]
    }

    func makeConnectInterceptors() -> [ClientInterceptor<FPConnectionCredentials, FPToken>] {
        return [AuthenticationInterceptor<FPConnectionCredentials, FPToken>()]
    }

    func makeDisconnectInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeDisconnectAllInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>()]
    }
}

struct UserServiceClientInterceptorFactory: FPUserServiceClientInterceptorFactoryProtocol {
    func makeRetrieveInterceptors() -> [ClientInterceptor<FPId, FPUser>] {
        return [AuthenticationInterceptor<FPId, FPUser>()]
    }

    func makeRetrieveMeInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPUser>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, FPUser>()]
    }

    func makeUpdateAvatarInterceptors() -> [ClientInterceptor<FPImageChunk, FPImage>] {
        return [AuthenticationInterceptor<FPImageChunk, FPImage>()]
    }

    func makeUpdateBioInterceptors() -> [ClientInterceptor<FPBio, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPBio, Google_Protobuf_Empty>()]
    }

    func makeSendEmailUpdateEmailInterceptors() -> [ClientInterceptor<FPEmail, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPEmail, Google_Protobuf_Empty>()]
    }

    func makeConfirmEmailUpdateInterceptors() -> [ClientInterceptor<FPToken, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPToken, Google_Protobuf_Empty>()]
    }

    func makeListBlockedInterceptors() -> [ClientInterceptor<FPPage, FPProfiles>] {
        return [AuthenticationInterceptor<FPPage, FPProfiles>()]
    }

    func makeUpdateBlockInterceptors() -> [ClientInterceptor<FPBlock, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPBlock, Google_Protobuf_Empty>()]
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeBanInterceptors() -> [ClientInterceptor<FPBanSentence, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPBanSentence, Google_Protobuf_Empty>()]
    }

    func makePromoteInterceptors() -> [ClientInterceptor<FPPromotion, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPPromotion, Google_Protobuf_Empty>()]
    }
}

struct PostServiceClientInterceptorFactory: FPPostServiceClientInterceptorFactoryProtocol {
    func makeListFeedInterceptors() -> [ClientInterceptor<FPVote, FPPost>] {
        return [AuthenticationInterceptor<FPVote, FPPost>()]
    }

    func makeListArchiveInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return [AuthenticationInterceptor<FPPage, FPPosts>()]
    }

    func makeListOwnPostsInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return [AuthenticationInterceptor<FPPage, FPPosts>()]
    }

    func makeListDraftsInterceptors() -> [ClientInterceptor<FPPage, FPPosts>] {
        return [AuthenticationInterceptor<FPPage, FPPosts>()]
    }

    func makeRetrieveInterceptors() -> [ClientInterceptor<FPId, FPPost>] {
        return [AuthenticationInterceptor<FPId, FPPost>()]
    }

    func makeCreateInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPId>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, FPId>()]
    }

    func makePublishInterceptors() -> [ClientInterceptor<FPPublication, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPPublication, Google_Protobuf_Empty>()]
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeUpdateSubscriptionInterceptors() -> [ClientInterceptor<FPSubscription, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPSubscription, Google_Protobuf_Empty>()]
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }
}

struct ChapterServiceClientInterceptorFactory: FPChapterServiceClientInterceptorFactoryProtocol {
    func makeCreateInterceptors() -> [ClientInterceptor<FPChapterLocation, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPChapterLocation, Google_Protobuf_Empty>()]
    }

    func makeMoveInterceptors() -> [ClientInterceptor<FPChapterRelocation, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPChapterRelocation, Google_Protobuf_Empty>()]
    }

    func makeUpdateTextInterceptors() -> [ClientInterceptor<FPChapterTextUpdate, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPChapterTextUpdate, Google_Protobuf_Empty>()]
    }

    func makeUpdateImageInterceptors() -> [ClientInterceptor<FPChapterImageUpdate, FPImage>] {
        return [AuthenticationInterceptor<FPChapterImageUpdate, FPImage>()]
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPChapterLocation, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPChapterLocation, Google_Protobuf_Empty>()]
    }
}

struct CommentServiceClientInterceptorFactory: FPCommentServiceClientInterceptorFactoryProtocol {
    func makeListInterceptors() -> [ClientInterceptor<FPPage, FPComments>] {
        return [AuthenticationInterceptor<FPPage, FPComments>()]
    }

    func makeCreateInterceptors() -> [ClientInterceptor<FPCommentCreation, FPId>] {
        return [AuthenticationInterceptor<FPCommentCreation, FPId>()]
    }

    func makeDeleteInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeAcknowledgeInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeReportInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }

    func makeAbsolveInterceptors() -> [ClientInterceptor<FPId, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPId, Google_Protobuf_Empty>()]
    }
}

struct NotificationServiceClientInterceptorFactory: FPNotificationServiceClientInterceptorFactoryProtocol {
    func makeCountInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, FPNotificationCount>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, FPNotificationCount>()]
    }

    func makeListInterceptors() -> [ClientInterceptor<FPPage, FPNotifications>] {
        return [AuthenticationInterceptor<FPPage, FPNotifications>()]
    }

    func makeClearInterceptors() -> [ClientInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<Google_Protobuf_Empty, Google_Protobuf_Empty>()]
    }

    func makeRegisterTokenInterceptors() -> [ClientInterceptor<FPMessagingToken, Google_Protobuf_Empty>] {
        return [AuthenticationInterceptor<FPMessagingToken, Google_Protobuf_Empty>()]
    }
}
