import Foundation
import GRPC
import SwiftProtobuf

extension ClientStreamingCall where RequestPayload == FPImageChunk, ResponsePayload == FPImage {
    func upload(_ image: Data?) {
        for chunk in image?.imageChunks ?? [] {
            _ = sendMessage(chunk)
        }

        _ = sendEnd()
    }
}
