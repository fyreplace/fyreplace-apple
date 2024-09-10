import XCTest

@testable
import Fyreplace

final class RegisterScreenTests: XCTestCase {
    class FakeScreen: RegisterScreenProtocol {
        var eventBus: EventBus
        var api: APIProtocol

        var isLoading = false
        var username = ""
        var email = ""
        var randomCode = ""
        var isWaitingForRandomCode = false
        var isRegistering = false
        var token = ""

        init(eventBus: EventBus, api: APIProtocol) {
            self.eventBus = eventBus
            self.api = api
        }
    }

    @MainActor
    func testUsernameMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.email = "email@example"

        for i in 0 ..< 3 {
            screen.username = .init(repeating: "a", count: i)
            XCTAssertFalse(screen.canSubmit)
        }

        for i in 3 ... 50 {
            screen.username = .init(repeating: "a", count: i)
            XCTAssertTrue(screen.canSubmit)
        }

        screen.username = .init(repeating: "a", count: 51)
        XCTAssertFalse(screen.canSubmit)
    }

    @MainActor
    func testEmailMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = "Example"

        for i in 0 ..< 3 {
            screen.email = .init(repeating: "@", count: i)
            XCTAssertFalse(screen.canSubmit)
        }

        for i in 3 ... 254 {
            screen.email = .init(repeating: "@", count: i)
            XCTAssertTrue(screen.canSubmit)
        }

        screen.email = .init(repeating: "@", count: 255)
        XCTAssertFalse(screen.canSubmit)
    }

    @MainActor
    func testEmailMustHaveAtSign() {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = "Example"
        screen.email = "email"
        XCTAssertFalse(screen.canSubmit)
        screen.email = "email@example"
        XCTAssertTrue(screen.canSubmit)
    }

    @MainActor
    func testInvalidUsernameProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.email = FakeClient.goodEmail
        screen.username = FakeClient.badUsername
        await screen.submit()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
        XCTAssertFalse(screen.isWaitingForRandomCode)
    }

    @MainActor
    func testInvalidEmailProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.badEmail
        await screen.submit()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
        XCTAssertFalse(screen.isWaitingForRandomCode)
    }

    @MainActor
    func testValidUsernameAndEmailProduceNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        await screen.submit()
        XCTAssertEqual(0, eventBus.storedEvents.count)
        XCTAssertTrue(screen.isWaitingForRandomCode)
    }

    @MainActor
    func testRandomCodeMustHaveCorrentLength() async {
        let screen = FakeScreen(eventBus: .init(), api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.isWaitingForRandomCode = true
        screen.randomCode = "abcd123"
        XCTAssertFalse(screen.canSubmit)
        screen.randomCode = "abcd1234"
        XCTAssertTrue(screen.canSubmit)
    }

    @MainActor
    func testInvalidRandomCodeProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.randomCode = FakeClient.badSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
    }

    @MainActor
    func testValidRandomCodeProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, api: .fake())
        screen.username = FakeClient.goodUsername
        screen.email = FakeClient.goodEmail
        screen.randomCode = FakeClient.goodSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        XCTAssertEqual(0, eventBus.storedEvents.count)
    }
}
