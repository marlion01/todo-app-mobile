import XCTest
@testable import TodoApp

@MainActor
final class CategoryListViewModelTests: XCTestCase {

    func test_init_loadsCategoriesFromStore() {
        let seed = [Category(name: "仕事")]
        let store = InMemoryCategoryStore(items: seed)

        let sut = CategoryListViewModel(store: store)

        XCTAssertEqual(sut.categories, seed)
    }

    func test_add_appendsAndPersists() throws {
        let store = InMemoryCategoryStore()
        let sut = CategoryListViewModel(store: store)

        let added = sut.add(name: "  仕事  ", colorHex: "#FF0000")

        XCTAssertNotNil(added)
        XCTAssertEqual(sut.categories.count, 1)
        XCTAssertEqual(sut.categories.first?.name, "仕事")
        XCTAssertEqual(sut.categories.first?.colorHex, "#FF0000")
        XCTAssertEqual(try store.load().count, 1)
    }

    func test_add_emptyName_returnsNilAndDoesNothing() {
        let sut = CategoryListViewModel(store: InMemoryCategoryStore())

        XCTAssertNil(sut.add(name: "   "))
        XCTAssertTrue(sut.categories.isEmpty)
    }

    func test_rename_updatesName() {
        let sut = CategoryListViewModel(store: InMemoryCategoryStore())
        guard let category = sut.add(name: "古い") else {
            return XCTFail("カテゴリの追加に失敗")
        }

        sut.rename(category, to: "新しい")

        XCTAssertEqual(sut.categories.first?.name, "新しい")
    }

    func test_rename_emptyName_isIgnored() {
        let sut = CategoryListViewModel(store: InMemoryCategoryStore())
        guard let category = sut.add(name: "元の名前") else {
            return XCTFail("カテゴリの追加に失敗")
        }

        sut.rename(category, to: "  ")

        XCTAssertEqual(sut.categories.first?.name, "元の名前")
    }

    func test_delete_removesCategory() {
        let sut = CategoryListViewModel(store: InMemoryCategoryStore())
        guard let category = sut.add(name: "削除対象") else {
            return XCTFail("カテゴリの追加に失敗")
        }

        sut.delete(category)

        XCTAssertTrue(sut.categories.isEmpty)
    }

    func test_deleteAll_clearsAllCategoriesAndPersists() throws {
        let store = InMemoryCategoryStore(items: [
            Category(name: "A"),
            Category(name: "B")
        ])
        let sut = CategoryListViewModel(store: store)

        sut.deleteAll()

        XCTAssertTrue(sut.categories.isEmpty)
        XCTAssertEqual(try store.load(), [])
    }

    func test_categoryWithId_returnsMatchingCategoryOrNil() {
        let sut = CategoryListViewModel(store: InMemoryCategoryStore())
        guard let category = sut.add(name: "仕事") else {
            return XCTFail("カテゴリの追加に失敗")
        }

        XCTAssertEqual(sut.category(with: category.id), category)
        XCTAssertNil(sut.category(with: nil))
        XCTAssertNil(sut.category(with: UUID()))
    }
}
