import Foundation
import HTTPTypes
import OpenAPIRuntime

struct AuthenticationMiddleware: ClientMiddleware {
    private let keychain = Keychain(service: "connection.token")

    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        let token = keychain.get()

        if !token.isEmpty {
            request.headerFields[.authorization] = "Bearer \(token)"
        }

        return try await next(request, body, baseURL)
    }
}
