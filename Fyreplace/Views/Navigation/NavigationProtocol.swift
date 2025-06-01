import Foundation

@MainActor
protocol NavigationProtocol {
    var eventBus: EventBus { get }

    func navigateToSettings()
}

@MainActor
extension NavigationProtocol {
    func handle(url: URL) {
        let fragment = url.fragment ?? ""

        switch url.path() {
        case "/login", "/register":
            Task {
                navigateToSettings()
                try? await Task.sleep(for: .seconds(0.3))
                eventBus.send(.connection(randomCode: fragment))
            }

        case "/settings/emails":
            let parts = fragment.split(separator: ":").map(String.init)

            if let email = parts.first, let code = parts.last {
                eventBus.send(.emailVerification(email: email, randomCode: code))
            }

        default:
            break
        }
    }
}
