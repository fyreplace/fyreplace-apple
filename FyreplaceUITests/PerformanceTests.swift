import XCTest

class PerformanceTests: XCTestCase {
    func testApplicationLaunchTime() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
