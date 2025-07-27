import Foundation
import GRPC
import ReactiveSwift

class Rpc: NSObject {
    static let didChangeChannelNotification = Notification.Name("Rpc.channelChange")
    private let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    lazy var channel: ClientConnection = makeChannel()

    override init() {
        super.init()
        NotificationCenter.default.reactive
            .notifications(forName: AppDelegate.didChangeEnvironmentNotification)
            .take(during: reactive.lifetime)
            .observeValues { [unowned self] in onAppDidChangeEnvironment($0) }
    }

    deinit {
        try? group.syncShutdownGracefully()
    }

    private func onAppDidChangeEnvironment(_ notification: Notification) {
        channel = makeChannel()
        NotificationCenter.default.post(name: Self.didChangeChannelNotification, object: self)
    }

    private func makeChannel() -> ClientConnection {
        let hostKey = UserDefaults.standard.string(forKey: "app:environment") ?? Bundle.main.apiDefaultHostKey
        let host = Bundle.main.getString(hostKey)
        let builder = host == Bundle.main.apiHostLocal
            ? ClientConnection.insecure(group: group)
            : ClientConnection.usingPlatformAppropriateTLS(for: group)
        return builder.connect(host: host, port: Bundle.main.apiPort)
    }
}
