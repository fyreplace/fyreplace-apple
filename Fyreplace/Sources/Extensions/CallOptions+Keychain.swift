import GRPC

extension CallOptions {
    private static let authToken = Keychain.authToken

    static var authenticated: Self {
        guard let data = authToken.get(),
              let token = String(data: data, encoding: .utf8)
        else { return .init() }
        return .init(customMetadata: .init(httpHeaders: ["authorization": "Bearer \(token)"]))
    }
}
