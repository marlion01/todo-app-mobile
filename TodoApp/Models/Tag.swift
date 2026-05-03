import Foundation

/// タグ文字列を扱うユーティリティ。
///
/// アプリ内ではタグは正規化済みの `String` (小文字・前後空白除去) として保持し、
/// ここでは正規化と入力パースのロジックのみを集約する。将来のタグ検索でも
/// `normalize` を経由して比較することで表記ゆれを吸収できる。
enum Tag {
    static func normalize(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func parse(_ input: String) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for chunk in input.split(whereSeparator: { $0 == "," || $0 == "\n" }) {
            let normalized = normalize(String(chunk))
            guard !normalized.isEmpty, !seen.contains(normalized) else { continue }
            seen.insert(normalized)
            result.append(normalized)
        }
        return result
    }
}
