import Foundation
import HTTPTypes
import OpenAPIRuntime

struct RequestIdMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.xRequestId] = UUID().uuidString
        return try await next(request, body, baseURL)
    }
}
