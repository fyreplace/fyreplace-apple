import Foundation

extension RegisterScreen {
    final class ViewModel: ObservableObject {
        @Published
        var username = ""

        @Published
        var email = ""

        var isUsernameValid: Bool { 3 ... 50 ~= username.count }
        var isEmailValid: Bool { 3 ... 254 ~= email.count && email.contains("@") }
        var canSubmit: Bool { isUsernameValid && isEmailValid }
    }
}
