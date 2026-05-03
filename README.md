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
├── TodoAppApp.swift           # @main エントリポイント
├── Models/
│   └── TodoItem.swift         # ドメインモデル
├── ViewModels/
│   └── TodoListViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── TodoListView.swift
│   ├── TodoRowView.swift
│   └── AddTodoView.swift
├── Services/
│   └── TodoStore.swift        # 永続化レイヤ (UserDefaults)
└── Resources/
    ├── Assets.xcassets/
    └── Info.plist

TodoAppTests/                  # XCTest (ユニット)
TodoAppUITests/                # XCUITest
```

## アーキテクチャ

- **MVVM** + SwiftUI (`ObservableObject` / `@Published`)
- 永続化は `TodoStore` プロトコル経由で抽象化 (デフォルトは `UserDefaults`)
- 依存注入で `TodoListViewModel` にテストダブルを差し込めます
