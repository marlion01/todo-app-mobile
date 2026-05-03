import XCTest
@testable import TodoApp

@MainActor
final class TodoListViewModelTests: XCTestCase {

    func test_init_loadsItemsFromStore() {
        let seed = [TodoItem(title: "既存タスク")]
        let store = InMemoryTodoStore(items: seed)

        let sut = TodoListViewModel(store: store)

        XCTAssertEqual(sut.items, seed)
    }

    func test_add_appendsTrimmedItem_andPersists() throws {
        let store = InMemoryTodoStore()
        let sut = TodoListViewModel(store: store)

        sut.add(title: "  牛乳を買う  ")

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items.first?.title, "牛乳を買う")

        let persisted = try store.load()
        XCTAssertEqual(persisted.count, 1)
    }

    func test_add_emptyTitle_isIgnored() {
        let sut = TodoListViewModel(store: InMemoryTodoStore())

        sut.add(title: "   ")

        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_add_withCategoryAndTags_normalizesAndDeduplicatesTags() {
        let categoryId = UUID()
        let sut = TodoListViewModel(store: InMemoryTodoStore())

        sut.add(
            title: "task",
            categoryId: categoryId,
            tags: ["Work", " urgent ", "WORK", ""]
        )

        XCTAssertEqual(sut.items.first?.categoryId, categoryId)
        XCTAssertEqual(sut.items.first?.tags, ["work", "urgent"])
    }

    func test_toggle_flipsCompletion() {
        let item = TodoItem(title: "切り替え対象")
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: [item]))

        sut.toggle(item)
        XCTAssertTrue(sut.items.first?.isCompleted == true)

        sut.toggle(sut.items[0])
        XCTAssertTrue(sut.items.first?.isCompleted == false)
    }

    func test_delete_removesItem() {
        let item = TodoItem(title: "削除対象")
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: [item]))

        sut.delete(item)

        XCTAssertTrue(sut.items.isEmpty)
    }

    func test_deleteAll_clearsAllItemsAndPersists() throws {
        let store = InMemoryTodoStore(items: [
            TodoItem(title: "A"),
            TodoItem(title: "B")
        ])
        let sut = TodoListViewModel(store: store)

        sut.deleteAll()

        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertEqual(try store.load(), [])
    }

    func test_pendingCount_excludesCompletedItems() {
        let items = [
            TodoItem(title: "A"),
            TodoItem(title: "B", isCompleted: true),
            TodoItem(title: "C")
        ]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        XCTAssertEqual(sut.pendingCount, 2)
    }

    // MARK: - フィルタ

    func test_filteredItems_whenFilterInactive_returnsAllItems() {
        let items = [TodoItem(title: "A"), TodoItem(title: "B")]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        XCTAssertEqual(sut.filteredItems, items)
    }

    func test_filteredItems_byCategory() {
        let cat1 = UUID()
        let cat2 = UUID()
        let items = [
            TodoItem(title: "A", categoryId: cat1),
            TodoItem(title: "B", categoryId: cat2),
            TodoItem(title: "C", categoryId: nil)
        ]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        sut.setFilter(category: cat1)

        XCTAssertEqual(sut.filteredItems.map(\.title), ["A"])
    }

    func test_toggleTag_addsAndRemovesTagInFilter() {
        let items = [
            TodoItem(title: "A", tags: ["work", "urgent"]),
            TodoItem(title: "B", tags: ["work"]),
            TodoItem(title: "C", tags: ["personal"])
        ]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        sut.toggleTag("Work") // 正規化されるはず
        XCTAssertEqual(Set(sut.filteredItems.map(\.title)), ["A", "B"])
        XCTAssertTrue(sut.filter.tags.contains("work"))

        sut.toggleTag("work")
        XCTAssertFalse(sut.filter.tags.contains("work"))
        XCTAssertEqual(sut.filteredItems.count, 3)
    }

    func test_availableTags_returnsUniqueSorted() {
        let items = [
            TodoItem(title: "A", tags: ["b", "a"]),
            TodoItem(title: "B", tags: ["a", "c"])
        ]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        XCTAssertEqual(sut.availableTags, ["a", "b", "c"])
    }

    func test_clearFilter_resetsAllConditions() {
        let sut = TodoListViewModel(store: InMemoryTodoStore())
        sut.setFilter(category: UUID())
        sut.toggleTag("a")
        sut.setSearchQuery("hello")
        XCTAssertTrue(sut.filter.isActive)

        sut.clearFilter()

        XCTAssertFalse(sut.filter.isActive)
    }
}
