import XCTest

final class NavigationTests: AppTests {
    func testNavigationIsComplete() {
        let feed = app.buttons["Feed"].firstMatch
        let notifications = app.buttons["Notifications"].firstMatch
        let archive = app.buttons["Archive"].firstMatch
        let drafts = app.buttons["Drafts"].firstMatch
        let published = app.buttons["Published"].firstMatch
        let settings = app.buttons["Settings"].firstMatch
        let login = app.segmentedButtons["Login"].firstMatch
        let register = app.segmentedButtons["Sign up"].firstMatch
        let tabs = app.segmentedButtonGroups["tabs"].firstMatch

        XCTAssert(feed.exists)
        XCTAssert(notifications.exists)
        XCTAssert(drafts.exists)
        XCTAssert(settings.exists)

        for (requiredDestination, optionalDestination) in [(notifications, archive), (drafts, published)] {
            if !optionalDestination.exists {
                requiredDestination.tap()
                XCTAssert(tabs.exists)
                XCTAssert(optionalDestination.exists)
            } else {
                requiredDestination.tap()
                XCTAssert(!tabs.exists)
            }
        }

        settings.tap()
        XCTAssert(tabs.exists)
        XCTAssert(login.exists)
        XCTAssert(register.exists)
    }

    func testNavigationShowsCorrectScreen() {
        for name in ["Feed", "Notifications", "Archive", "Drafts", "Published"] {
            app.buttons[name].firstMatch.tap()
            XCTAssert(app.descendants(matching: .any)[name.lowercased()].exists)
        }

        app.buttons["Settings"].firstMatch.tap()
        app.segmentedButtons["Login"].firstMatch.tap()
        XCTAssert(app.descendants(matching: .any)["login"].exists)
        app.segmentedButtons["Sign up"].firstMatch.tap()
        XCTAssert(app.descendants(matching: .any)["register"].exists)
    }
}
