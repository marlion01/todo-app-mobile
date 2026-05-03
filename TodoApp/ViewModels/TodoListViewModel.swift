import Combine
import Foundation

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var items: [TodoItem] = []
    @Published var filter: TodoFilter = .none
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

    func add(
        title: String,
        dueDate: Date? = nil,
        categoryId: UUID? = nil,
        tags: [String] = []
    ) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let normalizedTags = Tag.parse(tags.joined(separator: ","))
        let item = TodoItem(
            title: trimmed,
            dueDate: dueDate,
            categoryId: categoryId,
            tags: normalizedTags
        )
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

    func deleteAll() {
        guard !items.isEmpty else { return }
        items.removeAll()
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

    // MARK: - フィルタリング (将来のタグ検索／カテゴリ内検索の土台)

    var filteredItems: [TodoItem] {
        guard filter.isActive else { return items }
        return items.filter(filter.matches)
    }

    var availableTags: [String] {
        Array(Set(items.flatMap(\.tags))).sorted()
    }

    func setFilter(category: UUID?) {
        filter.categoryId = category
    }

    func toggleTag(_ tag: String) {
        let normalized = Tag.normalize(tag)
        guard !normalized.isEmpty else { return }
        if filter.tags.contains(normalized) {
            filter.tags.remove(normalized)
        } else {
            filter.tags.insert(normalized)
        }
    }

    func setSearchQuery(_ query: String) {
        filter.searchQuery = query
    }

    func clearFilter() {
        filter = .none
    }

    private func persist() {
        do {
            try store.save(items)
        } catch {
            errorMessage = "保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
