import XCTest

@testable
import Fyreplace

final class LoginScreenTests: XCTestCase {
    class FakeScreen: LoginScreenProtocol {
        var eventBus: EventBus
        var client: APIProtocol

        var isLoading = false
        var identifier = ""
        var randomCode = ""
        var isWaitingForRandomCode = false
        var token = ""

        init(eventBus: EventBus, client: APIProtocol) {
            self.eventBus = eventBus
            self.client = client
        }
    }

    @MainActor
    func testIdentifierMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), client: .fake())

        for i in 0 ..< 3 {
            screen.identifier = .init(repeating: "a", count: i)
            XCTAssertFalse(screen.canSubmit)
        }

        for i in 3 ... 254 {
            screen.identifier = .init(repeating: "a", count: i)
            XCTAssertTrue(screen.canSubmit)
        }

        screen.identifier = .init(repeating: "a", count: 255)
        XCTAssertFalse(screen.canSubmit)
    }

    @MainActor
    func testInvalidIdentifierProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, client: .fake())
        screen.identifier = FakeClient.badIdentifer
        await screen.submit()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
        XCTAssertFalse(screen.isWaitingForRandomCode)
    }

    @MainActor
    func testValidIdentifierProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, client: .fake())
        screen.identifier = FakeClient.goodIdentifer
        await screen.submit()
        XCTAssertEqual(0, eventBus.storedEvents.count)
        XCTAssertTrue(screen.isWaitingForRandomCode)
    }

    @MainActor
    func testRandomCodeMustHaveCorrentLength() async {
        let screen = FakeScreen(eventBus: .init(), client: .fake())
        screen.identifier = FakeClient.goodIdentifer
        screen.isWaitingForRandomCode = true
        screen.randomCode = "12345"
        XCTAssertFalse(screen.canSubmit)
        screen.randomCode = "123456"
        XCTAssertTrue(screen.canSubmit)
        screen.randomCode = "1234567"
        XCTAssertFalse(screen.canSubmit)
    }

    @MainActor
    func testInvalidRandomCodeProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, client: .fake())
        screen.identifier = FakeClient.goodIdentifer
        screen.randomCode = FakeClient.badSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
    }

    @MainActor
    func testValidRandomCodeProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(eventBus: eventBus, client: .fake())
        screen.identifier = FakeClient.goodIdentifer
        screen.randomCode = FakeClient.goodSecret
        screen.isWaitingForRandomCode = true
        await screen.submit()
        XCTAssertEqual(0, eventBus.storedEvents.count)
    }
}
