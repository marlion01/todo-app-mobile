import XCTest
@testable import TodoApp

final class TagTests: XCTestCase {

    func test_normalize_trimsAndLowercases() {
        XCTAssertEqual(Tag.normalize("  Work  "), "work")
        XCTAssertEqual(Tag.normalize("Urgent"), "urgent")
        XCTAssertEqual(Tag.normalize("急ぎ"), "急ぎ")
    }

    func test_parse_splitsByCommaAndDeduplicates() {
        XCTAssertEqual(
            Tag.parse(" work, Urgent ,work, , 急ぎ "),
            ["work", "urgent", "急ぎ"]
        )
    }

    func test_parse_splitsByNewline() {
        XCTAssertEqual(Tag.parse("a\nb\nA"), ["a", "b"])
    }

    func test_parse_handlesEmptyInput() {
        XCTAssertEqual(Tag.parse(""), [])
        XCTAssertEqual(Tag.parse(" , , "), [])
    }
}
