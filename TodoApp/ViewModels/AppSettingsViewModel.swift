import Foundation

@MainActor
final class AppSettingsViewModel: ObservableObject {
    @Published var settings: AppSettings {
        didSet {
            guard oldValue != settings else { return }
            persist()
        }
    }

    @Published var errorMessage: String?

    private let store: AppSettingsStore

    init(store: AppSettingsStore) {
        self.store = store
        do {
            self.settings = try store.load()
        } catch {
            self.settings = .default
            self.errorMessage = "設定の読み込みに失敗しました: \(error.localizedDescription)"
        }
    }

    func resetToDefaults() {
        settings = .default
    }

    private func persist() {
        do {
            try store.save(settings)
        } catch {
            errorMessage = "設定の保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
