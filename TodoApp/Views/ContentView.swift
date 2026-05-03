import SwiftUI

struct ContentView: View {
    var body: some View {
        TodoListView()
    }
}

#Preview {
    ContentView()
        .environmentObject(TodoListViewModel(store: InMemoryTodoStore(items: [
            TodoItem(title: "牛乳を買う"),
            TodoItem(title: "原稿を書く", isCompleted: true),
            TodoItem(title: "ジムに行く", dueDate: Date().addingTimeInterval(3600 * 24))
        ])))
}
