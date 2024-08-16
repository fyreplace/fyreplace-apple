import XCTest

@testable
import Fyreplace

final class RegisterScreenTests: XCTestCase {
    class FakeScreen: RegisterScreenProtocol {
        var eventBus: EventBus
        var client: APIProtocol

        var isLoading = false
        var username = ""
        var email = ""

        init(eventBus: EventBus, client: APIProtocol) {
            self.eventBus = eventBus
            self.client = client
        }
    }

    @MainActor
    func testUsernameMustHaveCorrectLength() {
        let screen = FakeScreen(eventBus: .init(), client: .fake())
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
        let screen = FakeScreen(eventBus: .init(), client: .fake())
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
        let screen = FakeScreen(eventBus: .init(), client: .fake())
        screen.username = "Example"
        screen.email = "email"
        XCTAssertFalse(screen.canSubmit)
        screen.email = "email@example"
        XCTAssertTrue(screen.canSubmit)
    }
}
