import Foundation
import Security

// MARK: - Secure Hardware-Backed Keychain Manager

public actor KeychainManager {
    public static let shared = KeychainManager()

    private let serviceName = "com.openai.chatgpt"

    public enum Key: String {
        case accessToken = "openai_access_token"
        case refreshToken = "openai_refresh_token"
        case idToken = "openai_id_token"
        case deviceId = "openai_device_id"
        case activeAccountId = "openai_active_account_id"
    }

    private init() {}

    public func save(key: Key, string: String) throws {
        guard let data = string.data(using: .utf8) else { return }
        try save(key: key, data: data)
    }

    public func save(key: Key, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    public func get(key: Key) -> String? {
        guard let data = getData(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    public func getData(key: Key) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return data
    }

    public func delete(key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    public func clearAll() {
        Key.allCases.forEach { delete(key: $0) }
    }
}

extension KeychainManager.Key: CaseIterable {}

public enum KeychainError: Error, LocalizedError {
    case unhandledError(status: OSStatus)

    public var errorDescription: String? {
        switch self {
        case .unhandledError(let status):
            return "Keychain operation failed with OSStatus code: \(status)"
        }
    }
}
