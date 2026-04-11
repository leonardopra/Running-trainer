import Foundation
import Security

final class SettingsStore {
    private let defaults = UserDefaults.standard
    private let prefsKey = "com.runningtrainer.ios.preferences"
    private let apiKeyService = "com.runningtrainer.ios"
    private let apiKeyAccount = "claudeApiKey"

    func load() -> UserPreferences {
        guard let data = defaults.data(forKey: prefsKey),
              var prefs = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return UserPreferences()
        }
        prefs.claudeApiKey = loadApiKey()
        return prefs
    }

    func save(_ prefs: UserPreferences) {
        var toSave = prefs
        let apiKey = prefs.claudeApiKey
        toSave.claudeApiKey = nil
        if let data = try? JSONEncoder().encode(toSave) {
            defaults.set(data, forKey: prefsKey)
        }
        if let key = apiKey, !key.isEmpty {
            saveApiKey(key)
        } else if apiKey != nil {
            deleteApiKey()
        }
    }

    func clear() {
        defaults.removeObject(forKey: prefsKey)
        deleteApiKey()
    }

    // MARK: - Keychain

    private func saveApiKey(_ key: String) {
        guard let data = key.data(using: .utf8) else { return }
        deleteApiKey()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: apiKeyService,
            kSecAttrAccount as String: apiKeyAccount,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadApiKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: apiKeyService,
            kSecAttrAccount as String: apiKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func deleteApiKey() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: apiKeyService,
            kSecAttrAccount as String: apiKeyAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
}
