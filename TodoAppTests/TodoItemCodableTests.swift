import XCTest
@testable import TodoApp

final class TodoItemCodableTests: XCTestCase {

    /// `categoryId` / `tags` 追加前のフォーマットも復元できること。
    func test_decode_legacyJSON_withoutCategoryAndTags_succeeds() throws {
        let id = UUID().uuidString
        let json = """
        {
            "id": "\(id)",
            "title": "古いタスク",
            "isCompleted": false,
            "createdAt": 0
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(TodoItem.self, from: json)

        XCTAssertEqual(decoded.title, "古いタスク")
        XCTAssertNil(decoded.categoryId)
        XCTAssertEqual(decoded.tags, [])
    }

    func test_roundtrip_preservesCategoryAndTags() throws {
        let original = TodoItem(
            title: "round trip",
            categoryId: UUID(),
            tags: ["a", "b"]
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TodoItem.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}
