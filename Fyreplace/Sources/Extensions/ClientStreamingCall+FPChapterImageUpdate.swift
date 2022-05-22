import Foundation
import GRPC
import SwiftProtobuf

extension ClientStreamingCall where RequestPayload == FPChapterImageUpdate, ResponsePayload == FPImage {
    func upload(_ image: Data, for postId: Data, at position: Int) {
        _ = sendMessage(.with {
            $0.location = .with {
                $0.postID = postId
                $0.position = UInt32(position)
            }
        })

        for chunk in image.imageChunks {
            _ = sendMessage(.with { $0.chunk = chunk })
        }

        _ = sendEnd()
    }
}
