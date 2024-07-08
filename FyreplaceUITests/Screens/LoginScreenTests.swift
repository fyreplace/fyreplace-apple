import XCTest

final class LoginScreenTests: AppTests {
    override func setUpWithError() throws {
        try super.setUpWithError()
        app.buttons["Settings"].firstMatch.tap()
        app.segmentedButtons["Login"].firstMatch.tap()
    }

    func testIdentifierMustHaveCorrectLength() {
        let identifier = app.textFields["identifier"].firstMatch
        let submit = app.buttons["submit"].firstMatch
        XCTAssertTrue(identifier.exists)
        XCTAssertTrue(submit.exists)
        XCTAssertFalse(submit.isEnabled)
        identifier.tap()

        for i in 1 ..< 3 {
            identifier.typeText(.init(repeating: "a", count: i))
            XCTAssertFalse(submit.isEnabled)
            identifier.typeText(.init(repeating: XCUIKeyboardKey.delete.rawValue, count: i))
        }

        identifier.typeText(.init(repeating: "a", count: 3))
        XCTAssertTrue(submit.isEnabled)
        identifier.typeText(.init(repeating: "a", count: 251))
        XCTAssertTrue(submit.isEnabled)

        identifier.typeText("a")
        XCTAssertFalse(submit.isEnabled)
    }
}
