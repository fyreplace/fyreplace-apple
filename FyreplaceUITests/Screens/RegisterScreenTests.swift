import XCTest

final class RegisterScreenTests: AppTests {
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.buttons["Settings"].firstMatch.tap()
        app.segmentedButtons["Sign up"].firstMatch.tap()
    }

    func testUsernameMustHaveCorrectLength() {
        let username = app.textFields["username"].firstMatch
        let email = app.textFields["email"].firstMatch
        let submit = app.buttons["submit"].firstMatch
        XCTAssertTrue(username.exists)
        XCTAssertTrue(submit.exists)
        XCTAssertFalse(submit.isEnabled)
        email.tap()
        email.typeText("email@example.org")
        username.tap()

        for i in 1 ..< 3 {
            username.typeText(.init(repeating: "a", count: i))
            XCTAssertFalse(submit.isEnabled)
            username.typeText(.init(repeating: XCUIKeyboardKey.delete.rawValue, count: i))
        }

        username.typeText(.init(repeating: "a", count: 3))
        XCTAssertTrue(submit.isEnabled)
        username.typeText(.init(repeating: "a", count: 47))
        XCTAssertTrue(submit.isEnabled)

        username.typeText("a")
        XCTAssertFalse(submit.isEnabled)
    }

    func testEmailMustHaveCorrectLength() {
        let username = app.textFields["username"].firstMatch
        let email = app.textFields["email"].firstMatch
        let submit = app.buttons["submit"].firstMatch
        XCTAssertTrue(username.exists)
        XCTAssertTrue(submit.exists)
        XCTAssertFalse(submit.isEnabled)
        username.tap()
        username.typeText("aaa")
        email.tap()

        for i in 1 ..< 3 {
            email.typeText(.init(repeating: "@", count: i))
            XCTAssertFalse(submit.isEnabled)
            email.typeText(.init(repeating: XCUIKeyboardKey.delete.rawValue, count: i))
        }

        email.typeText(.init(repeating: "@", count: 3))
        XCTAssertTrue(submit.isEnabled)
        email.typeText(.init(repeating: "@", count: 251))
        XCTAssertTrue(submit.isEnabled)

        email.typeText("@")
        XCTAssertFalse(submit.isEnabled)
    }

    func testEmailMustHaveAtSign() {
        let username = app.textFields["username"].firstMatch
        let email = app.textFields["email"].firstMatch
        let submit = app.buttons["submit"].firstMatch
        XCTAssertTrue(username.exists)
        XCTAssertTrue(submit.exists)
        XCTAssertFalse(submit.isEnabled)
        username.tap()
        username.typeText("aaa")
        email.tap()
        email.typeText("email")
        XCTAssertFalse(submit.isEnabled)
        email.typeText("@")
        XCTAssertTrue(submit.isEnabled)
    }
}
