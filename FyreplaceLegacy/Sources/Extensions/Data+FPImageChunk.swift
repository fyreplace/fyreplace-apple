import Foundation

extension Data {
    var imageChunks: [FPImageChunk] {
        let chunkCount = Int(ceil(Float(count) / Float(ImageSelector.imageChunkSize)))
        return (0 ..< chunkCount).map {
            let start = $0 * ImageSelector.imageChunkSize
            let end = Swift.min(start + ImageSelector.imageChunkSize, count)
            return FPImageChunk.with { $0.data = subdata(in: start ..< end) }
        }
    }
}
