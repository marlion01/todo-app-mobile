import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var todoViewModel: TodoListViewModel
    @StateObject private var categoryViewModel: CategoryListViewModel

    init() {
        _todoViewModel = StateObject(
            wrappedValue: TodoListViewModel(store: UserDefaultsTodoStore())
        )
        _categoryViewModel = StateObject(
            wrappedValue: CategoryListViewModel(store: UserDefaultsCategoryStore())
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoViewModel)
                .environmentObject(categoryViewModel)
        }
    }
}
