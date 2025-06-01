import Testing

@testable import Fyreplace

@Suite("Emails screen")
@MainActor
struct EmailsScreenTests {
    class FakeScreen: FakeScreenBase, EmailsScreenProtocol {
        var isLoading = false
        var showAddEmail = false
        var showVerifyEmail = false
        var emails: [Components.Schemas.Email] = []
        var newEmail = ""
        var unverifiedEmail = ""
        var randomCode = ""
    }

    @Test("Loading emails produces no failures")
    func loadEmailsProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.loadEmails()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.emails.count == 3)
    }

    @Test("Invalid email produces a failure")
    func invalidEmailProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.newEmail = FakeClient.badEmail
        await screen.addEmail()
        #expect(eventBus.storedEvents.filter(\.isFailure).count == 1)
        #expect(screen.emails.count == 0)
    }

    @Test("Valid email produces no failures")
    func validEmailProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.newEmail = FakeClient.goodEmail
        await screen.addEmail()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.emails.count == 1)
    }
}
