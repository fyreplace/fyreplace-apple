import Testing

@testable import Fyreplace

@Suite("Register screen")
@MainActor
struct RegisterScreenTests {
    class FakeScreen: FakeScreenBase, RegisterScreenProtocol {
        var isLoading = false
        var username = ""
        var email = ""
        var randomCode = ""
        var isWaitingForRandomCode = false
        var hasAcceptedTerms = false
        var isRegistering = false
        var token = ""
    }

    @Test("Username must have correct length")
    func usernameMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.email = FakeClient.goodEmail
        screen.hasAcceptedTerms = true

        for i in 0..<3 {
            screen.username = .init(repeating: "a", count: i)
            #expect(!screen.canSubmit)
        }

        for i in 3...50 {
            screen.username = .init(repeating: "a", count: i)
            #expect(screen.canSubmit)
        }

        screen.username = .init(repeating: "a", count: 51)
        #expect(!screen.canSubmit)
    }

    @Test("Email must have correct length")
    func emailMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = FakeClient.goodUsername
        screen.hasAcceptedTerms = true

        for i in 0..<3 {
            screen.email = .init(repeating: "@", count: i)
            #expect(!screen.canSubmit)
        }

        for i in 3...254 {
            screen.email = .init(repeating: "@", count: i)
            #expect(screen.canSubmit)
        }

        screen.email = .init(repeating: "@", count: 255)
        #expect(!screen.canSubmit)
    }

    @Test("Email must have @")
    func emailMustHaveAtSign() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = "email"
        screen.hasAcceptedTerms = true
        #expect(!screen.canSubmit)
        screen.email = "email@example"
        #expect(screen.canSubmit)
    }

    @Test("Terms must be accepted")
    func termsMustBeAccepted() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.hasAcceptedTerms = false
        #expect(!screen.canSubmit)
        screen.hasAcceptedTerms = true
        #expect(screen.canSubmit)
    }

    @Test("Invalid username produces a failure")
    func invalidUsernameProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.email = FakeClient.goodEmail
        screen.username = FakeClient.badUsername
        await screen.submit()
        #expect(eventBus.storedEvents.count == 1)
        #expect(eventBus.storedEvents.first is FailureEvent)
        #expect(!screen.isWaitingForRandomCode)
    }

    @Test("Invalid email produces a failure")
    func invalidEmailProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.badEmail
        await screen.submit()
        #expect(eventBus.storedEvents.count == 1)
        #expect(eventBus.storedEvents.first is FailureEvent)
        #expect(!screen.isWaitingForRandomCode)
    }

    @Test("Valid username and email produce no failures")
    func validUsernameAndEmailProduceNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        await screen.submit()
        #expect(eventBus.storedEvents.isEmpty)
        #expect(screen.isWaitingForRandomCode)
    }

    @Test("Random code must have correct length")
    func randomCodeMustHaveCorrentLength() async {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.randomCode = "abcd123"
        screen.isWaitingForRandomCode = true
        screen.hasAcceptedTerms = true
        #expect(!screen.canSubmit)
        screen.randomCode = "abcd1234"
        #expect(screen.canSubmit)
    }

    @Test("Invalid random code produces a failure")
    func invalidRandomCodeProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
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
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.randomCode = FakeClient.goodSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        #expect(eventBus.storedEvents.isEmpty)
    }
}
