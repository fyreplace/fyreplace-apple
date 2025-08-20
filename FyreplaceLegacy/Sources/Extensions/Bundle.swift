import Foundation

extension Bundle {
    static let bundleVersionKey = "CFBundleVersion"
    static let apiHostDefaultKeyKey = "FPApiHostDefaultKey"
    static let apiHostLocalKey = "FPApiHostLocal"
    static let apiHostDevKey = "FPApiHostDev"
    static let apiHostMainKey = "FPApiHostMain"
    static let apiPortKey = "FPApiPort"

    var bundleVersion: String { getString(Self.bundleVersionKey) }
    var apiDefaultHostKey: String { getString(Self.apiHostDefaultKeyKey) }
    var apiHostLocal: String { getString(Self.apiHostLocalKey) }
    var apiHostDev: String { getString(Self.apiHostDevKey) }
    var apiHostMain: String { getString(Self.apiHostMainKey) }
    var apiPort: Int { getInteger(Self.apiPortKey) }

    func getString(_ key: String) -> String {
        return Bundle.main.infoDictionary![key] as! String
    }

    func getInteger(_ key: String) -> Int {
        return Int(Bundle.main.infoDictionary![key] as! String)!
    }
}
