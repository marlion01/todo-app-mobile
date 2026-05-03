import Foundation
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var items: [TodoItem] = []
    @Published var errorMessage: String?

    private let store: TodoStore

    init(store: TodoStore) {
        self.store = store
        load()
    }

    func load() {
        do {
            items = try store.load()
        } catch {
            errorMessage = "読み込みに失敗しました: \(error.localizedDescription)"
        }
    }

    func add(title: String, dueDate: Date? = nil) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let item = TodoItem(title: trimmed, dueDate: dueDate)
        items.append(item)
        persist()
    }

    func toggle(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isCompleted.toggle()
        persist()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ item: TodoItem) {
        items.removeAll { $0.id == item.id }
        persist()
    }

    func update(_ item: TodoItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index] = item
        persist()
    }

    var pendingCount: Int {
        items.filter { !$0.isCompleted }.count
    }

    private func persist() {
        do {
            try store.save(items)
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
