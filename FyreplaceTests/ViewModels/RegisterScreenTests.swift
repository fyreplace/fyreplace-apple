import XCTest

@testable
import Fyreplace

final class RegisterScreenViewModelTests: XCTestCase {
    func testUsernameMustHaveCorrectLength() {
        let viewModel = RegisterScreen.ViewModel()
        viewModel.email = "email@example"

        for i in 0 ..< 3 {
            viewModel.username = .init(repeating: "a", count: i)
            XCTAssertFalse(viewModel.canSubmit)
        }

        for i in 3 ... 50 {
            viewModel.username = .init(repeating: "a", count: i)
            XCTAssertTrue(viewModel.canSubmit)
        }

        viewModel.username = .init(repeating: "a", count: 51)
        XCTAssertFalse(viewModel.canSubmit)
    }

    func testEmailMustHaveCorrectLength() {
        let viewModel = RegisterScreen.ViewModel()
        viewModel.username = "Example"

        for i in 0 ..< 3 {
            viewModel.email = .init(repeating: "@", count: i)
            XCTAssertFalse(viewModel.canSubmit)
        }

        for i in 3 ... 254 {
            viewModel.email = .init(repeating: "@", count: i)
            XCTAssertTrue(viewModel.canSubmit)
        }

        viewModel.email = .init(repeating: "@", count: 255)
        XCTAssertFalse(viewModel.canSubmit)
    }

    func testEmailMustHaveAtSign() {
        let viewModel = RegisterScreen.ViewModel()
        viewModel.username = "Example"
        viewModel.email = "email"
        XCTAssertFalse(viewModel.canSubmit)
        viewModel.email = "email@example"
        XCTAssertTrue(viewModel.canSubmit)
    }
}
