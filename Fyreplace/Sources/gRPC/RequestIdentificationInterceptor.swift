import Foundation
import GRPC
import NIOCore

class RequestIdentificationInterceptor<Request, Response>: ClientInterceptor<Request, Response> {
    override func send(_ part: GRPCClientRequestPart<Request>, promise: EventLoopPromise<Void>?, context: ClientInterceptorContext<Request, Response>) {
        if case var GRPCClientRequestPart.metadata(headers) = part {
            headers.add(name: "x-request-id", value: UUID().uuidString)
            super.send(.metadata(headers), promise: promise, context: context)
        } else {
            super.send(part, promise: promise, context: context)
        }
    }
}
