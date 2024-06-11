import Foundation

struct Config {
    static var main: Config {
        let dic = Bundle.main.infoDictionary!
        return Config(
            version: .init(
                build: dic.string("CFBundleVersion")!,
                marketing: dic.string("CFBundleShortVersionString")!
            ),
            fyreplace: .init(
                website: dic.url("FyreplaceWebsite")!,
                termsOfService: dic.url("FyreplaceTermsOfService")!,
                privacyPolicy: dic.url("FyreplacePrivacyPolicy")!
            ),
            sentry: .init(dsn: dic.string("SentryDSN"))
        )
    }

    let version: Version
    let fyreplace: Fyreplace
    let sentry: Sentry

    struct Version {
        let build: String
        let marketing: String

        func environment() -> String {
            let buildParts = build.split(separator: ".")
            return switch buildParts.last {
            case "3": "main"
            case "2": "hotfix"
            case "1": "release"
            default: "dev"
            }
        }
    }

    struct Fyreplace {
        let website: URL
        let termsOfService: URL
        let privacyPolicy: URL
    }

    struct Sentry {
        let dsn: String?
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
}
