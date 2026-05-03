import Foundation

protocol AppSettingsStore {
    func load() throws -> AppSettings
    func save(_ settings: AppSettings) throws
}

final class UserDefaultsAppSettingsStore: AppSettingsStore {
    private let key: String
    private let defaults: UserDefaults

    init(key: String = "app_settings_v1", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func load() throws -> AppSettings {
        guard let data = defaults.data(forKey: key) else { return .default }
        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            throw TodoStoreError.decodingFailed(error)
        }
    }

    func save(_ settings: AppSettings) throws {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: key)
        } catch {
            throw TodoStoreError.encodingFailed(error)
        }
    }
}

final class InMemoryAppSettingsStore: AppSettingsStore {
    private var settings: AppSettings

    init(settings: AppSettings = .default) {
        self.settings = settings
    }

    func load() throws -> AppSettings { settings }
    func save(_ settings: AppSettings) throws { self.settings = settings }
}
