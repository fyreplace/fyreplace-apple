import XCTest

@testable
import Fyreplace

final class LoginScreenTests: XCTestCase {
    struct FakeScreen: LoginScreenProtocol {
        var state: LoginScreen.State
        var eventBus: EventBus
        var client: APIProtocol
    }

    @MainActor
    func testIdentifierMustHaveCorrectLength() {
        let screen = FakeScreen(state: .init(), eventBus: .init(), client: .fake())

        for i in 0 ..< 3 {
            screen.state.identifier = .init(repeating: "a", count: i)
            XCTAssertFalse(screen.state.canSubmit)
        }

        for i in 3 ... 254 {
            screen.state.identifier = .init(repeating: "a", count: i)
            XCTAssertTrue(screen.state.canSubmit)
        }

        screen.state.identifier = .init(repeating: "a", count: 255)
        XCTAssertFalse(screen.state.canSubmit)
    }

    @MainActor
    func testInvalidIdentifierProducesFailure() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(state: .init(), eventBus: eventBus, client: .fake())
        screen.state.identifier = FakeClient.badIdentifer
        await screen.sendEmail()
        XCTAssertEqual(1, eventBus.storedEvents.count)
        XCTAssert(eventBus.storedEvents.first is FailureEvent)
    }

    @MainActor
    func testValidIdentifierProducesNoFailures() async {
        let eventBus = StoringEventBus()
        let screen = FakeScreen(state: .init(), eventBus: eventBus, client: .fake())
        screen.state.identifier = FakeClient.goodIdentifer
        await screen.sendEmail()
        XCTAssertEqual(0, eventBus.storedEvents.count)
    }
}
