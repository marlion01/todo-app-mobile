import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settingsViewModel: AppSettingsViewModel
    @EnvironmentObject private var todoViewModel: TodoListViewModel
    @EnvironmentObject private var categoryViewModel: CategoryListViewModel

    @State private var showingResetConfirmation = false
    @State private var showingClearTodosConfirmation = false
    @State private var showingClearCategoriesConfirmation = false

    var body: some View {
        Form {
            appearanceSection
            displaySection
            dataSection
            aboutSection
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "設定を初期値に戻しますか？",
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("初期値に戻す", role: .destructive) {
                settingsViewModel.resetToDefaults()
            }
            Button("キャンセル", role: .cancel) {}
        }
        .confirmationDialog(
            "Todo を全て削除しますか？",
            isPresented: $showingClearTodosConfirmation,
            titleVisibility: .visible
        ) {
            Button("全て削除", role: .destructive) {
                todoViewModel.deleteAll()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("この操作は取り消せません。")
        }
        .confirmationDialog(
            "カテゴリを全て削除しますか？",
            isPresented: $showingClearCategoriesConfirmation,
            titleVisibility: .visible
        ) {
            Button("全て削除", role: .destructive) {
                categoryViewModel.deleteAll()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("Todo に紐付いていたカテゴリ表示は消えますが、Todo 自体は削除されません。")
        }
    }

    // MARK: - Sections

    private var appearanceSection: some View {
        Section("外観") {
            Picker("テーマ", selection: $settingsViewModel.settings.theme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }

            Picker("文字サイズ", selection: $settingsViewModel.settings.fontSizeScale) {
                ForEach(FontSizeScale.allCases) { size in
                    Text(size.displayName).tag(size)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("アクセントカラー")
                AccentColorPickerRow(selection: $settingsViewModel.settings.accentColorHex)
            }
        }
    }

    private var displaySection: some View {
        Section {
            Toggle(
                "完了済みの Todo を表示",
                isOn: $settingsViewModel.settings.showCompletedTodos
            )
        } header: {
            Text("表示")
        } footer: {
            Text("オフにすると一覧から完了済みタスクを隠します。データは削除されません。")
        }
    }

    private var dataSection: some View {
        Section("データ") {
            Button {
                showingResetConfirmation = true
            } label: {
                Label("設定を初期値に戻す", systemImage: "arrow.counterclockwise")
            }

            Button(role: .destructive) {
                showingClearTodosConfirmation = true
            } label: {
                Label("Todo を全て削除", systemImage: "trash")
            }
            .disabled(todoViewModel.items.isEmpty)

            Button(role: .destructive) {
                showingClearCategoriesConfirmation = true
            } label: {
                Label("カテゴリを全て削除", systemImage: "folder.badge.minus")
            }
            .disabled(categoryViewModel.categories.isEmpty)
        }
    }

    private var aboutSection: some View {
        Section("バージョン情報") {
            LabeledContent("アプリ名", value: appName)
            LabeledContent("バージョン", value: appVersion)
        }
    }

    // MARK: - Bundle info

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "TodoApp"
    }

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(version) (\(build))"
    }
}

private struct AccentColorPickerRow: View {
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AppSettings.accentColorPalette, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selection == hex ? 2 : 0)
                        )
                        .onTapGesture { selection = hex }
                        .accessibilityLabel("カラー \(hex)")
                        .accessibilityAddTraits(selection == hex ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppSettingsViewModel(store: InMemoryAppSettingsStore()))
            .environmentObject(TodoListViewModel(store: InMemoryTodoStore(items: [
                TodoItem(title: "サンプル")
            ])))
            .environmentObject(CategoryListViewModel(store: InMemoryCategoryStore(items: [
                Category(name: "仕事")
            ])))
    }
}
