import XCTest
@testable import TodoApp

final class TodoFilterTests: XCTestCase {

    private let categoryA = UUID()
    private let categoryB = UUID()

    func test_emptyFilter_isInactive_andMatchesAll() {
        let filter = TodoFilter()
        XCTAssertFalse(filter.isActive)
        XCTAssertTrue(filter.matches(TodoItem(title: "x")))
        XCTAssertTrue(filter.matches(TodoItem(title: "x", categoryId: categoryA, tags: ["a"])))
    }

    func test_categoryFilter_matchesOnlySpecifiedCategory() {
        let filter = TodoFilter(categoryId: categoryA)
        XCTAssertTrue(filter.isActive)
        XCTAssertTrue(filter.matches(TodoItem(title: "x", categoryId: categoryA)))
        XCTAssertFalse(filter.matches(TodoItem(title: "x", categoryId: categoryB)))
        XCTAssertFalse(filter.matches(TodoItem(title: "x", categoryId: nil)))
    }

    func test_tagFilter_requiresAllTagsAsAnd() {
        let filter = TodoFilter(tags: ["a", "b"])
        XCTAssertTrue(filter.matches(TodoItem(title: "x", tags: ["a", "b", "c"])))
        XCTAssertFalse(filter.matches(TodoItem(title: "x", tags: ["a"])))
        XCTAssertFalse(filter.matches(TodoItem(title: "x", tags: [])))
    }

    func test_searchQuery_matchesTitleSubstringCaseInsensitive() {
        let filter = TodoFilter(searchQuery: "Buy")
        XCTAssertTrue(filter.matches(TodoItem(title: "buy milk")))
        XCTAssertTrue(filter.matches(TodoItem(title: "Need to BUY bread")))
        XCTAssertFalse(filter.matches(TodoItem(title: "drink water")))
    }

    func test_combinedFilters_areAnded() {
        let filter = TodoFilter(categoryId: categoryA, tags: ["urgent"], searchQuery: "report")
        let matching = TodoItem(
            title: "Write Report",
            categoryId: categoryA,
            tags: ["urgent", "work"]
        )
        XCTAssertTrue(filter.matches(matching))

        let wrongCategory = TodoItem(title: "Write Report", categoryId: categoryB, tags: ["urgent"])
        XCTAssertFalse(filter.matches(wrongCategory))

        let missingTag = TodoItem(title: "Write Report", categoryId: categoryA, tags: [])
        XCTAssertFalse(filter.matches(missingTag))

        let titleMismatch = TodoItem(title: "Other", categoryId: categoryA, tags: ["urgent"])
        XCTAssertFalse(filter.matches(titleMismatch))
    }
}
