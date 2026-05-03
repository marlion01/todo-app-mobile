import Foundation

protocol CategoryStore {
    func load() throws -> [Category]
    func save(_ categories: [Category]) throws
}

final class UserDefaultsCategoryStore: CategoryStore {
    private let key: String
    private let defaults: UserDefaults

    init(key: String = "todo_categories_v1", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func load() throws -> [Category] {
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([Category].self, from: data)
        } catch {
            throw TodoStoreError.decodingFailed(error)
        }
    }

    func save(_ categories: [Category]) throws {
        do {
            let data = try JSONEncoder().encode(categories)
            defaults.set(data, forKey: key)
        } catch {
            throw TodoStoreError.encodingFailed(error)
        }
    }
}

final class InMemoryCategoryStore: CategoryStore {
    private var items: [Category]

    init(items: [Category] = []) {
        self.items = items
    }

    func load() throws -> [Category] { items }
    func save(_ items: [Category]) throws { self.items = items }
}
