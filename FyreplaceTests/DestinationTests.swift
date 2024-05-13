import XCTest

@testable
import Fyreplace

final class DestinationTests: XCTestCase {
    func testPropertiesExists() {
        for first in Destination.allCases {
            XCTAssertNotNil(first.titleKey)
            XCTAssertNotEqual(first.titleKey, "")
            XCTAssertNotNil(first.icon)
            XCTAssertNotEqual(first.icon, "")
        }
    }

    func testPropertiesAreUnique() {
        for first in Destination.allCases {
            for second in Destination.allCases where first != second {
                XCTAssertNotEqual(first.titleKey, second.titleKey)
                XCTAssertNotEqual(first.icon, second.icon)
            }
        }
    }
}
