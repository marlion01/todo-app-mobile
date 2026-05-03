import SwiftUI

struct ContentView: View {
    var body: some View {
        TodoListView()
    }
}

#Preview {
    let category = Category(name: "仕事", colorHex: "#0A84FF")
    let categoryVM = CategoryListViewModel(store: InMemoryCategoryStore(items: [category]))
    let todoVM = TodoListViewModel(store: InMemoryTodoStore(items: [
        TodoItem(title: "牛乳を買う", tags: ["買い物"]),
        TodoItem(title: "原稿を書く", isCompleted: true, categoryId: category.id, tags: ["執筆"]),
        TodoItem(title: "ジムに行く", dueDate: Date().addingTimeInterval(3600 * 24))
    ]))
    let settingsVM = AppSettingsViewModel(store: InMemoryAppSettingsStore())
    return ContentView()
        .environmentObject(todoVM)
        .environmentObject(categoryVM)
        .environmentObject(settingsVM)
}
