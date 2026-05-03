import Foundation

struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var categoryId: UUID?
    var tags: [String]

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        categoryId: UUID? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.categoryId = categoryId
        self.tags = tags
    }

    enum CodingKeys: String, CodingKey {
        case id, title, isCompleted, createdAt, dueDate, categoryId, tags
    }

    // categoryId / tags は後から追加したフィールドのため、旧データとの互換のために
    // decodeIfPresent でデフォルト値を補う。
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        categoryId = try container.decodeIfPresent(UUID.self, forKey: .categoryId)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
    }
}
