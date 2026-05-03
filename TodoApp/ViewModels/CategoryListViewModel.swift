import Foundation

@MainActor
final class CategoryListViewModel: ObservableObject {
    @Published private(set) var categories: [Category] = []
    @Published var errorMessage: String?

    private let store: CategoryStore

    init(store: CategoryStore) {
        self.store = store
        load()
    }

    func load() {
        do {
            categories = try store.load()
        } catch {
            errorMessage = "カテゴリの読み込みに失敗しました: \(error.localizedDescription)"
        }
    }

    @discardableResult
    func add(name: String, colorHex: String = Category.defaultColor) -> Category? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let category = Category(name: trimmed, colorHex: colorHex)
        categories.append(category)
        persist()
        return category
    }

    func rename(_ category: Category, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index].name = trimmed
        persist()
    }

    func update(_ category: Category) {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else { return }
        categories[index] = category
        persist()
    }

    func delete(at offsets: IndexSet) {
        categories.remove(atOffsets: offsets)
        persist()
    }

    func delete(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        persist()
    }

    func category(with id: UUID?) -> Category? {
        guard let id else { return nil }
        return categories.first(where: { $0.id == id })
    }

    private func persist() {
        do {
            try store.save(categories)
        } catch {
            errorMessage = "カテゴリの保存に失敗しました: \(error.localizedDescription)"
        }
    }
}
