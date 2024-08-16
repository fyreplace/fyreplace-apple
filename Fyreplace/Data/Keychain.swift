import Foundation
import Security
import SwiftUI

struct Keychain {
    let service: String

    private var query: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecAttrLabel: Config.default.app.name,
            kSecAttrService: service,
        ]
    }

    func get() -> String {
        var info = query
        info[kSecReturnData] = true
        var itemReference: CFTypeRef?
        guard SecItemCopyMatching(info as CFDictionary, &itemReference) == errSecSuccess,
              let data = itemReference as? Data,
              let value = String(data: data, encoding: .utf8)
        else { return "" }
        return value
    }

    @KeychainActor
    func set(_ value: String) -> Bool {
        guard !value.isEmpty else { return delete() }
        let data = value.data(using: .utf8)

        if SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary) == errSecSuccess {
            return true
        } else {
            var info = query
            info[kSecValueData] = data
            return SecItemAdd(info as CFDictionary, nil) == errSecSuccess
        }
    }

    @KeychainActor
    func delete() -> Bool {
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

@globalActor
actor KeychainActor: GlobalActor {
    static let shared = KeychainActor()
}

@propertyWrapper
struct KeychainStorage: DynamicProperty {
    @ObservedObject
    private var cache: KeychainCache

    private let keychain: Keychain

    var wrappedValue: String {
        get {
            cache.value
        }

        nonmutating set(value) {
            cache.value = value

            Task {
                await keychain.set(value)
            }
        }
    }

    init(_ key: String) {
        let cleanKey = key.replacing(".", with: ":")
        keychain = .init(service: cleanKey)
        cache = .shared(for: cleanKey, defaultValue: keychain.get())
    }
}

class KeychainCache: ObservableObject {
    private static var instances: [String: KeychainCache] = [:]

    private let key: String

    @Published
    var value: String

    init(key: String, defaultValue: String) {
        self.key = key
        value = defaultValue
    }

    static func shared(for key: String, defaultValue: String) -> KeychainCache {
        if let instance = instances[key] {
            return instance
        }

        let instance = KeychainCache(key: key, defaultValue: defaultValue)
        instances[key] = instance
        return instance
    }
}
