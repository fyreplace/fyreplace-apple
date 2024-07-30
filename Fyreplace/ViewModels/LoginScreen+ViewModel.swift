import Foundation

extension LoginScreen {
    final class ViewModel: ObservableObject {
        @Published
        var identifier = ""

        var canSubmit: Bool { 3 ... 254 ~= identifier.count }
    }
}
