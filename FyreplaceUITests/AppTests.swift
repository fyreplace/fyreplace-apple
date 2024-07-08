import XCTest

class AppTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launchArguments += ["--ui-tests"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }
}
