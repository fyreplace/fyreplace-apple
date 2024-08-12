import XCTest

@testable
import Fyreplace

final class RegisterScreenTests: XCTestCase {
    struct FakeScreen: RegisterScreenProtocol {
        var state: RegisterScreen.State
        var eventBus: EventBus
        var client: APIProtocol
    }

    @MainActor
    func testUsernameMustHaveCorrectLength() {
        let screen = FakeScreen(state: .init(), eventBus: .init(), client: .fake())
        screen.state.email = "email@example"

        for i in 0 ..< 3 {
            screen.state.username = .init(repeating: "a", count: i)
            XCTAssertFalse(screen.state.canSubmit)
        }

        for i in 3 ... 50 {
            screen.state.username = .init(repeating: "a", count: i)
            XCTAssertTrue(screen.state.canSubmit)
        }

        screen.state.username = .init(repeating: "a", count: 51)
        XCTAssertFalse(screen.state.canSubmit)
    }

    @MainActor
    func testEmailMustHaveCorrectLength() {
        let screen = FakeScreen(state: .init(), eventBus: .init(), client: .fake())
        screen.state.username = "Example"

        for i in 0 ..< 3 {
            screen.state.email = .init(repeating: "@", count: i)
            XCTAssertFalse(screen.state.canSubmit)
        }

        for i in 3 ... 254 {
            screen.state.email = .init(repeating: "@", count: i)
            XCTAssertTrue(screen.state.canSubmit)
        }

        screen.state.email = .init(repeating: "@", count: 255)
        XCTAssertFalse(screen.state.canSubmit)
    }

    @MainActor
    func testEmailMustHaveAtSign() {
        let screen = FakeScreen(state: .init(), eventBus: .init(), client: FakeClient())
        screen.state.username = "Example"
        screen.state.email = "email"
        XCTAssertFalse(screen.state.canSubmit)
        screen.state.email = "email@example"
        XCTAssertTrue(screen.state.canSubmit)
    }
}
