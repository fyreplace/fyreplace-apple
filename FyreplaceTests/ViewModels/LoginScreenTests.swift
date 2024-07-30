import XCTest

@testable
import Fyreplace

final class LoginScreenViewModelTests: XCTestCase {
    func testIdentifierMustHaveCorrectLength() {
        let viewModel = LoginScreen.ViewModel()

        for i in 0 ..< 3 {
            viewModel.identifier = .init(repeating: "a", count: i)
            XCTAssertFalse(viewModel.canSubmit)
        }

        for i in 3 ... 254 {
            viewModel.identifier = .init(repeating: "a", count: i)
            XCTAssertTrue(viewModel.canSubmit)
        }

        viewModel.identifier = .init(repeating: "a", count: 255)
        XCTAssertFalse(viewModel.canSubmit)
    }
}
