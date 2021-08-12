import Foundation
import Security

public struct Keychain {
    public static var authToken: Keychain {
        Keychain(securityClass: kSecClassGenericPassword, service: "auth:token")
    }

    private let securityClass: CFString
    private let service: String
    private var query: [CFString: Any] {
        [kSecClass: securityClass, kSecAttrService: service]
    }

    private init(securityClass: CFString, service: String) {
        self.securityClass = securityClass
        self.service = service
    }

    public func get() -> Data? {
        var info = query
        info[kSecReturnData] = true
        var data: CFTypeRef?
        SecItemCopyMatching(info as CFDictionary, &data)
        return data as? Data
    }

    public func set(_ data: Data) -> Bool {
        var info = query
        info[kSecValueData] = data
        _ = delete()
        return SecItemAdd(info as CFDictionary, nil) == errSecSuccess
    }

    public func delete() -> Bool {
        SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

enum KeychainError: String, Error {
    case get = "Get"
    case set = "Set"
    case delete = "Delete"

    var alertText: String { "Keychain.Error.\(self.rawValue)" }
}
