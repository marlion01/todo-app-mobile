# TodoApp (iOS)

Swift / SwiftUI 製の Todo 共有アプリ (iOS) の雛形リポジトリです。

## 必要環境

- macOS 14 以降
- Xcode 15.0 以降 (Swift 5.9 / iOS 17 SDK)
- [Homebrew](https://brew.sh/)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) — `project.yml` から `.xcodeproj` を生成
- [SwiftLint](https://github.com/realm/SwiftLint) — Lint
- [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) — フォーマッタ

```bash
brew install xcodegen swiftlint swiftformat
```

## セットアップ

```bash
# 1. .xcodeproj を生成
xcodegen generate

# 2. Xcode で開く
open TodoApp.xcodeproj
```

## ビルド / テスト (CLI)

```bash
# ビルド
xcodebuild \
  -project TodoApp.xcodeproj \
  -scheme TodoApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  build

# テスト
xcodebuild \
  -project TodoApp.xcodeproj \
  -scheme TodoApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  test
```

## ディレクトリ構成

```
TodoApp/
├── TodoAppApp.swift                # @main エントリポイント
├── Models/
│   ├── TodoItem.swift              # Todo 本体 (categoryId / tags を保持)
│   ├── Category.swift              # カテゴリ (id / name / colorHex)
│   ├── Tag.swift                   # タグ正規化ユーティリティ
│   └── TodoFilter.swift            # 絞り込み条件 (検索クエリ用フィールド込み)
├── ViewModels/
│   ├── TodoListViewModel.swift     # 一覧 + フィルタ + タグ操作
│   └── CategoryListViewModel.swift # カテゴリ CRUD
├── Views/
│   ├── ContentView.swift
│   ├── TodoListView.swift          # フィルタバー + リスト
│   ├── TodoRowView.swift           # カテゴリバッジ・タグ表示込み
│   ├── AddTodoView.swift           # カテゴリ Picker + タグ入力
│   ├── FilterBarView.swift         # カテゴリチップによる絞り込み
│   ├── CategoryBadgeView.swift
│   └── CategoryManagementView.swift
├── Services/
│   ├── TodoStore.swift             # Todo 永続化 (UserDefaults / InMemory)
│   └── CategoryStore.swift         # Category 永続化
├── Support/
│   └── Color+Hex.swift
└── Resources/
    ├── Assets.xcassets/
    └── Info.plist

TodoAppTests/                       # XCTest (ユニット)
TodoAppUITests/                     # XCUITest
```

## アーキテクチャ

- **MVVM** + SwiftUI (`ObservableObject` / `@Published`)
- 永続化は `TodoStore` / `CategoryStore` プロトコル経由で抽象化 (デフォルトは `UserDefaults`)
- 依存注入で各 ViewModel にテストダブル (`InMemory*Store`) を差し込めます

### カテゴリとタグ

- 1 つの Todo は **0 or 1 件のカテゴリ** に属し、**0 件以上のタグ** を持ちます。
- タグは `Tag.normalize` で「前後空白除去 + 小文字化」を行い、表記ゆれを吸収します。
- 絞り込み条件は `TodoFilter` に集約 (`categoryId` / `tags` / `searchQuery`)。
  AND 条件で評価され、`TodoListViewModel.filteredItems` から取り出します。
- `TodoFilter.searchQuery` は次フェーズの **タグ検索 / カテゴリ内検索** 実装用に
  事前に確保されており、`setSearchQuery(_:)` で書き込むだけで一覧に反映されます。

### 旧データとの互換性

`TodoItem` に `categoryId` / `tags` を追加した際の互換性を保つため、
`init(from:)` で `decodeIfPresent` を用いてデフォルト値を補います
(旧 JSON はそのまま復元可能。`TodoItemCodableTests` で検証)。
