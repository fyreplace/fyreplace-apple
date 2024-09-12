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
            attemptAuthentication(with: url.fragment() ?? "")

        default:
            break
        }
    }

    func attemptAuthentication(with randomCode: String) {
        navigateToSettings()

        Task {
            try? await Task.sleep(for: .seconds(0.5))
            eventBus.send(.randomCode(randomCode))
        }
    }
}
