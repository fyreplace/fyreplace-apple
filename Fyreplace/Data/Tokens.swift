import BackgroundTasks

let tokenRefreshDelaySeconds: Double = 60 * 60 * 24

@available(macOS, unavailable)
@Sendable
func tokenRefreshBackgroundTask() async {
    let keychain = Keychain(service: "connection.token")
    guard !keychain.get().isEmpty else { return }
    scheduleTokenRefresh()

    let environment: ServerEnvironment

    if let environmentString = UserDefaults.standard.string(forKey: "connection.environment") {
        environment = .init(rawValue: environmentString)!
    } else {
        environment = .default
    }

    if let newToken = await refreshToken(using: Config.default.app.api.client(for: environment)) {
        _ = await keychain.set(newToken)
    }
}

@available(macOS, unavailable)
func scheduleTokenRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "app.fyreplace.Fyreplace.tokenRefresh")
    request.earliestBeginDate = .init(timeIntervalSinceNow: tokenRefreshDelaySeconds)
    try? BGTaskScheduler.shared.submit(request)
}

func refreshToken(using api: APIProtocol) async -> String? {
    guard let response = try? await api.getNewToken().ok,
          let newToken = try? await String(collecting: response.body.plainText, upTo: 1024)
    else { return nil }
    return newToken
}
