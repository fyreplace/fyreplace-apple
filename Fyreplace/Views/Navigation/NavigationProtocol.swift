import Foundation

protocol NavigationProtocol {
    var eventBus: EventBus { get }

    func navigateToSettings()
}

@MainActor
extension NavigationProtocol {
    func handle(url: URL) {
        switch url.path().trimmingPrefix("/") {
        case "login", "register":
            Task {
                await attemptAuthentication(with: url.fragment() ?? "")
            }

        default:
            break
        }
    }

    private func attemptAuthentication(with randomCode: String) async {
        navigateToSettings()
        try? await Task.sleep(for: .seconds(0.3))
        eventBus.send(.randomCode(randomCode))
    }
}
