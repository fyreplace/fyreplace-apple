import Foundation

extension FPPost {
    static let wasNotFoundNotification = Notification.Name("FPPost.wasNotFound")
    static let wasSubscribedToNotification = Notification.Name("FPPost.wasSubscribedTo")
    static let wasUnsubscribedFromNotification = Notification.Name("FPPost.wasUnsubscribedFrom")
    static let wasSeenNotification = Notification.Name("FPPost.wasSeen")
    static let wasDeletedNotification = Notification.Name("FPPost.wasDeleted")
    static let draftWasCreatedNotification = Notification.Name("FPPost.draftWasCreated")
    static let draftWasUpdatedNotification = Notification.Name("FPPost.draftWasUpdated")
    static let draftWasDeletedNotification = Notification.Name("FPPost.draftWasDeleted")
    static let draftWasPublishedNotification = Notification.Name("FPPost.draftWasPublished")
}
