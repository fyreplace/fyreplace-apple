import XCTest

extension XCUIApplication {
    var segmentedButtonGroups: XCUIElementQuery {
        #if os(macOS)
            radioGroups
        #else
            segmentedControls
        #endif
    }

    var segmentedButtons: XCUIElementQuery {
        #if os(macOS)
            radioButtons
        #else
            buttons
        #endif
    }
}
