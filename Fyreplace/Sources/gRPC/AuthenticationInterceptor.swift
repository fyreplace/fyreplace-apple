import GRPC
import NIOCore

class AuthenticationInterceptor<Request, Response>: ClientInterceptor<Request, Response> {
    private let authToken = Keychain.authToken

    override func send(_ part: GRPCClientRequestPart<Request>, promise: EventLoopPromise<Void>?, context: ClientInterceptorContext<Request, Response>) {
        if case var GRPCClientRequestPart.metadata(headers) = part,
           let data = authToken.get(),
           let token = String(data: data, encoding: .utf8)
        {
            headers.add(name: "authorization", value: "Bearer \(token)")
            super.send(.metadata(headers), promise: promise, context: context)
        } else {
            super.send(part, promise: promise, context: context)
        }
    }
}
