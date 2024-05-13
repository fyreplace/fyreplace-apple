import Foundation

struct Config {
    static var main: Config {
        let dic = Bundle.main.infoDictionary!
        return Config(
            websiteLink: .init(string: dic["FPWebsite"] as! String)!,
            termsOfServiceLink: .init(string: dic["FPTermsOfService"] as! String)!,
            privacyPolicyLink: .init(string: dic["FPPrivacyPolicy"] as! String)!
        )
    }

    let websiteLink: URL
    let termsOfServiceLink: URL
    let privacyPolicyLink: URL
}
