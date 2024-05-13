import XCTest

final class MainTests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    func testInitialScreenIsFeed() {
        let feed = app.descendants(matching: .any)["feed"].firstMatch
        XCTAssert(feed.exists)
    }

    func testNavigationIsComplete() {
        let feed = app.buttons["Feed"].firstMatch
        let notifications = app.buttons["Notifications"].firstMatch
        let archive = app.buttons["Archive"].firstMatch
        let drafts = app.buttons["Drafts"].firstMatch
        let published = app.buttons["Published"].firstMatch
        let settings = app.buttons["Settings"].firstMatch
        let picker = app.segmentedControls["tabs"].firstMatch

        XCTAssert(feed.exists)
        XCTAssert(notifications.exists)
        XCTAssert(drafts.exists)
        XCTAssert(settings.exists)

        for (requiredDestination, optionalDestination) in [(notifications, archive), (drafts, published)] {
            if !optionalDestination.exists {
                requiredDestination.tap()
                XCTAssert(picker.exists)
                XCTAssert(optionalDestination.exists)
            } else {
                requiredDestination.tap()
                XCTAssert(!picker.exists)
            }
        }
    }

    func testNavigationShowsCorrectScreen() {
        for name in ["Feed", "Notifications", "Archive", "Drafts", "Published", "Settings"] {
            let button = app.buttons[name].firstMatch
            button.tap()
            XCTAssert(app.descendants(matching: .any)[name.lowercased()].exists)
        }
    }
}
