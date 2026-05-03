import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var viewModel: TodoListViewModel
    @State private var isPresentingAddSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Todo")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Label("追加", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("\(viewModel.pendingCount) 件未完了")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddTodoView { title, dueDate in
                    viewModel.add(title: title, dueDate: dueDate)
                }
            }
            .alert(
                "エラー",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                presenting: viewModel.errorMessage
            ) { _ in
                Button("OK", role: .cancel) {}
            } message: { message in
                Text(message)
            }
        }
    }

    private var list: some View {
        List {
            ForEach(viewModel.items) { item in
                TodoRowView(item: item) {
                    viewModel.toggle(item)
                }
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("Todo がありません", systemImage: "checklist")
        } description: {
            Text("右上の + ボタンから追加できます。")
        }
    }
}

#Preview {
    TodoListView()
        .environmentObject(TodoListViewModel(store: InMemoryTodoStore(items: [
            TodoItem(title: "サンプル 1"),
            TodoItem(title: "サンプル 2", isCompleted: true)
        ])))
}
