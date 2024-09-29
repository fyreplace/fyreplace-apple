import Testing

@testable import Fyreplace

@Suite("Login screen")
@MainActor
struct LoginScreenTests {
    class FakeScreen: FakeScreenBase, LoginScreenProtocol {
        var isLoading = false
        var identifier = ""
        var randomCode = ""
        var isWaitingForRandomCode = false
        var token = ""
    }

    @Test("Identifier must have correct length")
    func identifierMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())

        for i in 0..<3 {
            screen.identifier = .init(repeating: "a", count: i)
            #expect(!screen.canSubmit)
        }

        for i in 3...254 {
            screen.identifier = .init(repeating: "a", count: i)
            #expect(screen.canSubmit)
        }

        screen.identifier = .init(repeating: "a", count: 255)
        #expect(!screen.canSubmit)
    }

    @Test("Invalid identifier produces a failure")
    func invalidIdentifierProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.identifier = FakeClient.badUsername
        await screen.submit()
        #expect(eventBus.storedEvents.count == 1)
        #expect(eventBus.storedEvents.first is FailureEvent)
        #expect(!screen.isWaitingForRandomCode)
    }

    @Test("Valid identifier produces no failures")
    func validIdentifierProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.identifier = FakeClient.goodUsername
        await screen.submit()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.isWaitingForRandomCode)
    }

    @Test("Password identifier produces a failure")
    func passwordIdentifierProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.identifier = FakeClient.passwordUsername
        await screen.submit()
        #expect(eventBus.storedEvents.count == 1)
        #expect(screen.isWaitingForRandomCode)
    }

    @Test("Random code must have correct length")
    func randomCodeMustHaveCorrentLength() async {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.identifier = FakeClient.goodUsername
        screen.isWaitingForRandomCode = true
        screen.randomCode = "abcd123"
        #expect(!screen.canSubmit)
        screen.randomCode = "abcd1234"
        #expect(screen.canSubmit)
    }

    @Test("Invalid random code produces a failure")
    func invalidRandomCodeProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.identifier = FakeClient.goodUsername
        screen.randomCode = FakeClient.badSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        #expect(eventBus.storedEvents.count == 1)
        #expect(eventBus.storedEvents.first is FailureEvent)
    }

    @Test("Valid random code produces no failures")
    func validRandomCodeProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.identifier = FakeClient.goodUsername
        screen.randomCode = FakeClient.goodSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        #expect(eventBus.storedEvents.isEmpty)
    }
}
