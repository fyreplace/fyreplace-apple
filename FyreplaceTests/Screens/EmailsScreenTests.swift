import Testing

@testable import Fyreplace

@Suite("Emails screen")
@MainActor
struct EmailsScreenTests {
    class FakeScreen: FakeScreenBase, EmailsScreenProtocol {
        var emails: [Fyreplace.Components.Schemas.Email] = []
    }

    @Test("Loading emails produces no failures")
    func loadEmailsProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        await screen.loadEmails()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.emails.count == 3)
    }
}
