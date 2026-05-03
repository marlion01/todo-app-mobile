import Foundation

/// Todo 一覧の絞り込み条件。
///
/// 将来追加予定の「タグ検索」「カテゴリ内検索」を見越して、
/// 検索クエリ用フィールドも先に確保している。
/// `matches(_:)` の中で複数条件を AND で合成する。
struct TodoFilter: Equatable {
    var categoryId: UUID?
    var tags: Set<String>
    var searchQuery: String

    init(categoryId: UUID? = nil, tags: Set<String> = [], searchQuery: String = "") {
        self.categoryId = categoryId
        self.tags = tags
        self.searchQuery = searchQuery
    }

    static let none = TodoFilter()

    var isActive: Bool {
        categoryId != nil
            || !tags.isEmpty
            || !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func matches(_ item: TodoItem) -> Bool {
        if let categoryId, item.categoryId != categoryId {
            return false
        }
        if !tags.isEmpty {
            let itemTagSet = Set(item.tags)
            if !tags.isSubset(of: itemTagSet) {
                return false
            }
        }
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !trimmedQuery.isEmpty, !item.title.lowercased().contains(trimmedQuery) {
            return false
        }
        return true
    }
}
