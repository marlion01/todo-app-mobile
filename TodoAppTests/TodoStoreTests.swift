import XCTest
@testable import TodoApp

final class UserDefaultsTodoStoreTests: XCTestCase {

    private var defaults: UserDefaults!
    private let suiteName = "TodoStoreTests.\(UUID().uuidString)"

    override func setUpWithError() throws {
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
    }

    func test_load_whenEmpty_returnsEmptyArray() throws {
        let sut = UserDefaultsTodoStore(key: "items", defaults: defaults)

        XCTAssertEqual(try sut.load(), [])
    }

    func test_save_then_load_returnsSameItems() throws {
        let sut = UserDefaultsTodoStore(key: "items", defaults: defaults)
        let items = [
            TodoItem(title: "1"),
            TodoItem(title: "2", isCompleted: true)
        ]

        try sut.save(items)

        XCTAssertEqual(try sut.load(), items)
    }
}
