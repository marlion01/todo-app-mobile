import SwiftUI

struct TodoListView: View {
    @EnvironmentObject private var viewModel: TodoListViewModel
    @EnvironmentObject private var settingsViewModel: AppSettingsViewModel
    @State private var isPresentingAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FilterBarView()
                    .padding(.vertical, 8)
                Divider()
                Group {
                    if displayedItems.isEmpty {
                        emptyState
                    } else {
                        list
                    }
                }
            }
            .navigationTitle("Todo")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    NavigationLink {
                        CategoryManagementView()
                    } label: {
                        Label("カテゴリ", systemImage: "folder")
                    }
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("設定", systemImage: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddSheet = true
                    } label: {
                        Label("追加", systemImage: "plus")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Text("\(viewModel.pendingCount) 件未完了")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(isPresented: $isPresentingAddSheet) {
                AddTodoView { draft in
                    viewModel.add(
                        title: draft.title,
                        dueDate: draft.dueDate,
                        categoryId: draft.categoryId,
                        tags: draft.tags
                    )
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

    /// `filter` (カテゴリ/タグ/検索) と設定 `showCompletedTodos` の両方を適用した表示用リスト。
    private var displayedItems: [TodoItem] {
        let base = viewModel.filteredItems
        guard !settingsViewModel.settings.showCompletedTodos else { return base }
        return base.filter { !$0.isCompleted }
    }

    private var list: some View {
        List {
            ForEach(displayedItems) { item in
                TodoRowView(item: item) {
                    viewModel.toggle(item)
                }
            }
            .onDelete(perform: deleteFiltered)
        }
        .listStyle(.plain)
    }

    // 表示中リストの index は items の index と一致しないため、id 経由で削除する。
    private func deleteFiltered(at offsets: IndexSet) {
        let visible = displayedItems
        let targets = offsets.map { visible[$0] }
        for target in targets {
            viewModel.delete(target)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.filter.isActive {
            ContentUnavailableView {
                Label("条件に一致する Todo がありません", systemImage: "line.3.horizontal.decrease.circle")
            } description: {
                Text("フィルタを解除すると全て表示されます。")
            } actions: {
                Button("フィルタを解除") {
                    viewModel.clearFilter()
                }
            }
        } else if !settingsViewModel.settings.showCompletedTodos, !viewModel.items.isEmpty {
            ContentUnavailableView {
                Label("未完了の Todo はありません", systemImage: "checkmark.circle")
            } description: {
                Text("設定で「完了済みの Todo を表示」をオンにすると一覧に表示されます。")
            }
        } else {
            ContentUnavailableView {
                Label("Todo がありません", systemImage: "checklist")
            } description: {
                Text("右上の + ボタンから追加できます。")
            }
        }
    }
}

#Preview {
    let category = Category(name: "仕事", colorHex: "#0A84FF")
    let categoryVM = CategoryListViewModel(store: InMemoryCategoryStore(items: [category]))
    let todoVM = TodoListViewModel(store: InMemoryTodoStore(items: [
        TodoItem(title: "サンプル 1", categoryId: category.id, tags: ["urgent"]),
        TodoItem(title: "サンプル 2", isCompleted: true, tags: ["done"])
    ]))
    let settingsVM = AppSettingsViewModel(store: InMemoryAppSettingsStore())
    return TodoListView()
        .environmentObject(todoVM)
        .environmentObject(categoryVM)
        .environmentObject(settingsVM)
}
