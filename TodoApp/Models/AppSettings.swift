import Foundation

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "システムに合わせる"
        case .light: return "ライト"
        case .dark: return "ダーク"
        }
    }
}

enum FontSizeScale: String, Codable, CaseIterable, Identifiable {
    case small
    case medium
    case large
    case extraLarge

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .small: return "小"
        case .medium: return "標準"
        case .large: return "大"
        case .extraLarge: return "特大"
        }
    }
}

struct AppSettings: Codable, Equatable {
    var theme: AppTheme
    var fontSizeScale: FontSizeScale
    var accentColorHex: String
    var showCompletedTodos: Bool

    init(
        theme: AppTheme = .system,
        fontSizeScale: FontSizeScale = .medium,
        accentColorHex: String = AppSettings.defaultAccentColor,
        showCompletedTodos: Bool = true
    ) {
        self.theme = theme
        self.fontSizeScale = fontSizeScale
        self.accentColorHex = accentColorHex
        self.showCompletedTodos = showCompletedTodos
    }

    static let `default` = AppSettings()

    static let defaultAccentColor = "#0A84FF"

    static let accentColorPalette: [String] = [
        "#FF3B30", "#FF9500", "#FFCC00", "#34C759",
        "#5AC8FA", "#0A84FF", "#5856D6", "#AF52DE", "#FF2D55"
    ]

    enum CodingKeys: String, CodingKey {
        case theme, fontSizeScale, accentColorHex, showCompletedTodos
    }

    // 将来フィールドが追加された場合や旧バージョンとの互換性のために
    // すべて decodeIfPresent + デフォルト値で復元する。
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theme = try container.decodeIfPresent(AppTheme.self, forKey: .theme) ?? .system
        fontSizeScale = try container.decodeIfPresent(FontSizeScale.self, forKey: .fontSizeScale) ?? .medium
        accentColorHex = try container.decodeIfPresent(String.self, forKey: .accentColorHex)
            ?? AppSettings.defaultAccentColor
        showCompletedTodos = try container.decodeIfPresent(Bool.self, forKey: .showCompletedTodos) ?? true
    }
}
