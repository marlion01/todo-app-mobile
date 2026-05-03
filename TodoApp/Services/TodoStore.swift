import Foundation

protocol TodoStore {
    func load() throws -> [TodoItem]
    func save(_ items: [TodoItem]) throws
}

enum TodoStoreError: Error {
    case decodingFailed(Error)
    case encodingFailed(Error)
}

final class UserDefaultsTodoStore: TodoStore {
    private let key: String
    private let defaults: UserDefaults

    init(key: String = "todo_items_v1", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func load() throws -> [TodoItem] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            throw TodoStoreError.decodingFailed(error)
        }
    }

    func save(_ items: [TodoItem]) throws {
        do {
            let data = try JSONEncoder().encode(items)
            defaults.set(data, forKey: key)
        } catch {
            throw TodoStoreError.encodingFailed(error)
        }
    }
}

final class InMemoryTodoStore: TodoStore {
    private var items: [TodoItem]

    init(items: [TodoItem] = []) {
        self.items = items
    }

    func load() throws -> [TodoItem] { items }
    func save(_ items: [TodoItem]) throws { self.items = items }
}
