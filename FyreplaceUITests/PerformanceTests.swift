import XCTest

@MainActor
final class PerformanceTests: XCTestCase {
    func testApplicationLaunchTime() {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
