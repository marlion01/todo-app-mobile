import SwiftUI

extension AppTheme {
    /// `nil` の場合はシステムのテーマに従う。
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension FontSizeScale {
    /// iOS のデフォルトの本文サイズは `.large` のため、`medium` を `.large` にマップする。
    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .small: return .small
        case .medium: return .large
        case .large: return .xLarge
        case .extraLarge: return .xxxLarge
        }
    }
}

extension AppSettings {
    var accentColor: Color { Color(hex: accentColorHex) }
}
