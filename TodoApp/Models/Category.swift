import Foundation

struct Category: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String

    init(id: UUID = UUID(), name: String, colorHex: String = Category.defaultColor) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    static let defaultColor = "#0A84FF"

    static let presetColors: [String] = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#5AC8FA", "#0A84FF", "#5856D6", "#AF52DE", "#FF2D55"
    ]
}
