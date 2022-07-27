import Foundation

extension FPPost {
    static let notFoundNotification = Notification.Name("FPPost.notFound")
    static let subscriptionNotification = Notification.Name("FPPost.subscription")
    static let unsubscriptionNotification = Notification.Name("FPPost.unsubscription")
    static let deletionNotification = Notification.Name("FPPost.deletion")
    static let draftCreationNotification = Notification.Name("FPPost.draftCreation")
    static let draftUpdateNotification = Notification.Name("FPPost.draftUpdate")
    static let draftDeletionNotification = Notification.Name("FPPost.draftDeletion")
    static let draftPublicationNotification = Notification.Name("FPPost.publication")
}
