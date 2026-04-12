import Combine
import Foundation
import GRPC

class Rpc: NSObject {
    static let didChangeChannelNotification = Notification.Name("Rpc.channelChange")
    lazy var channel: ClientConnection = makeChannel()
    private let group = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        NotificationCenter.default
            .publisher(for: AppDelegate.didChangeEnvironmentNotification)
            .sink { [unowned self] in onAppDidChangeEnvironment($0) }
            .store(in: &cancellables)
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
        let port = switch host {
        case Bundle.main.apiHostLocal: Bundle.main.apiPortLocal
        case Bundle.main.apiHostDev: Bundle.main.apiPortDev
        case Bundle.main.apiHostMain: Bundle.main.apiPortMain
        default: 0
        }
        let builder = host == Bundle.main.apiHostLocal
            ? ClientConnection.insecure(group: group)
            : ClientConnection.usingPlatformAppropriateTLS(for: group)
        return builder.connect(host: host, port: port)
    }
}
