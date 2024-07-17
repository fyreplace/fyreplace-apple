import Foundation

struct Config {
    static var `default`: Config {
        let data = Bundle.main.infoDictionary!
        return Config(
            version: .init(
                build: data.string("CFBundleVersion")!,
                marketing: data.string("CFBundleShortVersionString")!
            ),
            app: .init(data.dictionary("App")!),
            sentry: .init(data.dictionary("Sentry")!)
        )
    }

    let version: Version
    let app: App
    let sentry: Sentry

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
        let info: Info
        let api: Api

        init(_ data: [String: Any]) {
            info = .init(data.dictionary("Info")!)
            api = .init(data.dictionary("Api")!)
        }

        struct Info {
            let website: URL
            let termsOfService: URL
            let privacyPolicy: URL

            init(_ data: [String: Any]) {
                website = data.url("Website")!
                termsOfService = data.url("TermsOfService")!
                privacyPolicy = data.url("PrivacyPolicy")!
            }
        }

        struct Api {
            let main: URL
            let dev: URL
            let local: URL

            init(_ data: [String: Any]) {
                main = data.url("Main")!
                dev = data.url("Dev")!
                local = data.url("Local")!
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

private extension [String: Any] {
    func string(_ key: String) -> String? {
        return self[key] as? String
    }

    func url(_ key: String) -> URL? {
        guard let s = string(key) else { return nil }
        return .init(string: s)
    }

    func dictionary(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
}
