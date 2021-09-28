import SwiftProtobuf
import GRPC

extension ClientStreamingCall where RequestPayload == FPImageChunk, ResponsePayload == Google_Protobuf_Empty {
    func upload(image: Data?) {
        guard let image = image else {
            _ = sendEnd()
            return
        }

        let totalSize = image.count
        let chunkCount = Int(ceil(Float(totalSize) / Float(ImageSelector.imageChunkSize)))

        for i in 0..<chunkCount {
            let start = i * ImageSelector.imageChunkSize
            let end = min(start + ImageSelector.imageChunkSize, totalSize)
            _ = sendMessage(FPImageChunk.with { $0.data = image.subdata(in: start..<end) })
        }

        _ = sendEnd()
    }
}
