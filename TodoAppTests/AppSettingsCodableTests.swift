import XCTest
@testable import TodoApp

final class AppSettingsCodableTests: XCTestCase {

    /// 旧バージョン (キーが存在しない JSON) でもデフォルト値で復元できる。
    func test_decode_emptyJSON_usesDefaults() throws {
        let data = "{}".data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded, .default)
    }

    func test_decode_partialJSON_fillsMissingFieldsWithDefaults() throws {
        let json = """
        { "theme": "dark" }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(AppSettings.self, from: json)

        XCTAssertEqual(decoded.theme, .dark)
        XCTAssertEqual(decoded.fontSizeScale, .medium)
        XCTAssertEqual(decoded.accentColorHex, AppSettings.defaultAccentColor)
        XCTAssertTrue(decoded.showCompletedTodos)
    }

    func test_roundtrip_preservesAllFields() throws {
        let original = AppSettings(
            theme: .dark,
            fontSizeScale: .extraLarge,
            accentColorHex: "#AABBCC",
            showCompletedTodos: false
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(AppSettings.self, from: data)

        XCTAssertEqual(decoded, original)
    }
}
