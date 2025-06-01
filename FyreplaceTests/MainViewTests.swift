import Testing

@testable import Fyreplace

@Suite("")
@MainActor
struct MainViewTests {
    class FakeView: FakeScreenBase, MainViewProtocol {
        var showError = false
        var showFailure = false
        var showEmailVerified = false
        var errors: [CriticalError] = []
        var failures: [Failure] = []
        var verifiedEmail = ""
        var token = ""
    }

    @Test("Invalid random code produces a failure")
    func invalidRandomCodeProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeView(eventBus: eventBus, api: .fake())
        let email = Components.Schemas.Email.make(verified: false)
        await screen.verifyEmail(email: email.email, code: FakeClient.badSecret)
        #expect(eventBus.storedEvents.filter(\.isFailure).count == 1)
    }

    @Test("Valid random code produces no failures")
    func validRandomCodeProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeView(eventBus: eventBus, api: .fake())
        let email = Components.Schemas.Email.make(verified: false)
        await screen.verifyEmail(email: email.email, code: FakeClient.goodSecret)
        #expect(eventBus.storedEvents.filter(\.isFailure).isEmpty)
    }
}
