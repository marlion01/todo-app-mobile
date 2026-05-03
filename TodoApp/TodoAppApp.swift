import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var todoViewModel: TodoListViewModel
    @StateObject private var categoryViewModel: CategoryListViewModel
    @StateObject private var settingsViewModel: AppSettingsViewModel

    init() {
        _todoViewModel = StateObject(
            wrappedValue: TodoListViewModel(store: UserDefaultsTodoStore())
        )
        _categoryViewModel = StateObject(
            wrappedValue: CategoryListViewModel(store: UserDefaultsCategoryStore())
        )
        _settingsViewModel = StateObject(
            wrappedValue: AppSettingsViewModel(store: UserDefaultsAppSettingsStore())
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoViewModel)
                .environmentObject(categoryViewModel)
                .environmentObject(settingsViewModel)
                .preferredColorScheme(settingsViewModel.settings.theme.colorScheme)
                .dynamicTypeSize(settingsViewModel.settings.fontSizeScale.dynamicTypeSize)
                .tint(settingsViewModel.settings.accentColor)
        }
    }
}
