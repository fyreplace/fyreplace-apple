import OpenAPIURLSession
import SwiftUI

struct Config {
    static let `default` = Config(from: Bundle.main)

    let version: Version
    let app: App
    let sentry: Sentry

    init(from bundle: Bundle) {
        let data = bundle.infoDictionary!
        version = .init(
            build: data.string("CFBundleVersion")!,
            marketing: data.string("CFBundleShortVersionString")!
        )
        app = .init(data.dictionary("App")!)
        sentry = .init(data.dictionary("Sentry")!)
    }

    struct Version {
        let build: String
        let marketing: String
        var environment: String {
            switch build.split(separator: ".").last {
            case "3": "main"
            case "2": "hotfix"
            case "1": "release"
            default: "dev"
            }
        }
    }

    struct App {
        let name: String
        let info: Info
        let api: Api

        init(_ data: [String: Any]) {
            name = data.string("Name")!
            info = .init(data.dictionary("Info")!)
            api = .init(data.dictionary("Api")!)
        }

        struct Info {
            let website: URL
            let termsOfService: URL
            let privacyPolicy: URL
            let sourceCode: URL

            init(_ data: [String: Any]) {
                website = data.url("Website")!
                termsOfService = data.url("TermsOfService")!
                privacyPolicy = data.url("PrivacyPolicy")!
                sourceCode = data.url("SourceCode")!
            }
        }

        struct Api {
            let main: URL
            let dev: URL
            #if DEBUG
                let local: URL
            #endif

            init(_ data: [String: Any]) {
                main = data.url("Main")!
                dev = data.url("Dev")!
                #if DEBUG
                    local = data.url("Local")!
                #endif
            }

            func url(for environment: ServerEnvironment) -> URL {
                return switch environment {
                case .main:
                    main
                case .dev:
                    dev
                #if DEBUG
                    case .local:
                        local
                #endif
                }
            }

            func client(for environment: ServerEnvironment) -> Client {
                let configuration = URLSessionConfiguration.default
                configuration.waitsForConnectivity = true

                #if os(iOS)
                    configuration.multipathServiceType = .handover
                #endif

                return Client(
                    serverURL: url(for: environment),
                    configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
                    transport: URLSessionTransport(
                        configuration: .init(session: .init(configuration: configuration))
                    ),
                    middlewares: [RequestIdMiddleware(), AuthenticationMiddleware()]
                )
            }
        }
    }

    struct Sentry {
        let dsn: String?

        init(_ data: [String: Any]) {
            dsn = data.string("Dsn")
        }
    }
}

extension [String: Any] {
    fileprivate func string(_ key: String) -> String? {
        return self[key] as? String
    }

    fileprivate func url(_ key: String) -> URL? {
        guard let s = string(key) else { return nil }
        return .init(string: s)
    }

    fileprivate func dictionary(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}

private struct ConfigEnvironmentKey: EnvironmentKey {
    static let defaultValue = Config(from: Bundle.main)
}

extension EnvironmentValues {
    var config: Config {
        get { self[ConfigEnvironmentKey.self] }
        set { self[ConfigEnvironmentKey.self] = newValue }
    }
}
