import XCTest
@testable import TodoApp

@MainActor
final class AppSettingsViewModelTests: XCTestCase {

    func test_init_loadsFromStore() {
        let custom = AppSettings(
            theme: .dark,
            fontSizeScale: .large,
            accentColorHex: "#FF0000",
            showCompletedTodos: false
        )
        let store = InMemoryAppSettingsStore(settings: custom)

        let sut = AppSettingsViewModel(store: store)

        XCTAssertEqual(sut.settings, custom)
    }

    func test_init_whenStoreEmpty_usesDefault() {
        let sut = AppSettingsViewModel(store: InMemoryAppSettingsStore())

        XCTAssertEqual(sut.settings, .default)
        XCTAssertEqual(sut.settings.theme, .system)
        XCTAssertEqual(sut.settings.fontSizeScale, .medium)
        XCTAssertTrue(sut.settings.showCompletedTodos)
    }

    func test_settingsChange_persistsToStore() throws {
        let store = InMemoryAppSettingsStore()
        let sut = AppSettingsViewModel(store: store)

        sut.settings.theme = .dark
        sut.settings.fontSizeScale = .extraLarge
        sut.settings.showCompletedTodos = false

        let persisted = try store.load()
        XCTAssertEqual(persisted.theme, .dark)
        XCTAssertEqual(persisted.fontSizeScale, .extraLarge)
        XCTAssertFalse(persisted.showCompletedTodos)
    }

    func test_settingsAssignmentToSameValue_doesNotTriggerExtraPersist() throws {
        let store = CountingAppSettingsStore()
        let sut = AppSettingsViewModel(store: store)
        let saveCountAfterInit = store.saveCount

        sut.settings = sut.settings // 同値代入

        XCTAssertEqual(store.saveCount, saveCountAfterInit)
    }

    func test_resetToDefaults_resetsAllFields() {
        let store = InMemoryAppSettingsStore(settings: AppSettings(
            theme: .dark,
            fontSizeScale: .extraLarge,
            accentColorHex: "#FF00FF",
            showCompletedTodos: false
        ))
        let sut = AppSettingsViewModel(store: store)

        sut.resetToDefaults()

        XCTAssertEqual(sut.settings, .default)
    }
}

private final class CountingAppSettingsStore: AppSettingsStore {
    private(set) var saveCount = 0
    private var current: AppSettings = .default

    func load() throws -> AppSettings { current }

    func save(_ settings: AppSettings) throws {
        saveCount += 1
        current = settings
    }
}
