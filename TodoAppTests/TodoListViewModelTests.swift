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

    func test_pendingCount_excludesCompletedItems() {
        let items = [
            TodoItem(title: "A"),
            TodoItem(title: "B", isCompleted: true),
            TodoItem(title: "C")
        ]
        let sut = TodoListViewModel(store: InMemoryTodoStore(items: items))

        XCTAssertEqual(sut.pendingCount, 2)
    }
}
