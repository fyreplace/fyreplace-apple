import Foundation
import Security
import SwiftUI

struct Keychain {
    private let service: String

    private var query: [CFString: Any] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrLabel: Config.default.app.name,
            kSecAttrService: service,
        ]
    }

    init(service: String) {
        self.service = service.replacing(".", with: ":")
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
        let attributes = [kSecValueData: data] as CFDictionary

        if SecItemUpdate(query as CFDictionary, attributes) == errSecSuccess {
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

@MainActor
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
        keychain = .init(service: key)
        cache = .shared(for: key)
    }
}

@MainActor
class KeychainCache: ObservableObject {
    private static var instances: [String: KeychainCache] = [:]

    private let key: String

    @Published
    var value: String

    init(key: String, defaultValue: String) {
        self.key = key
        value = defaultValue
    }

    static func shared(for key: String) -> KeychainCache {
        if let instance = instances[key] {
            return instance
        }

        let keychain = Keychain(service: key)
        let instance = KeychainCache(key: key, defaultValue: keychain.get())
        instances[key] = instance
        return instance
    }
}
