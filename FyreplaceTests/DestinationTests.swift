import XCTest

@testable
import Fyreplace

final class DestinationTests: XCTestCase {
    func testPropertiesExists() {
        for destination in Destination.allCases {
            XCTAssertNotEqual(destination.titleKey, "")

            if destination.topLevel {
                XCTAssertNotEqual(destination.icon, "")
            }
        }
    }

    func testPropertiesAreUnique() {
        for first in Destination.allCases {
            for second in Destination.allCases where first != second {
                XCTAssertNotEqual(first.titleKey, second.titleKey)

                if first.icon != "" {
                    XCTAssertNotEqual(first.icon, second.icon)
                }
            }
        }
    }

    func testParentsDoNotLoop() {
        for destination in Destination.allCases {
            XCTAssertNotEqual(destination, destination.parent)
            XCTAssertNotEqual(destination, destination.parent?.parent)
        }
    }
}
