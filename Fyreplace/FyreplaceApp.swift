import Sentry
import SwiftUI

@main
struct FyreplaceApp: App {
    init() {
        guard let dsn = Config.default.sentry.dsn, !dsn.isEmpty else { return }

        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = Config.default.version.environment
            #if DEBUG
                options.tracesSampleRate = 1
                options.enableSpotlight = true
                options.configureProfiling = {
                    $0.sessionSampleRate = 1
                }
            #endif
        }
    }

    var body: some Scene {
        MainScene()
    }
}
