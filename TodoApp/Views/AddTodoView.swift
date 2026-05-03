import SwiftUI

struct TodoItemDraft {
    let title: String
    let dueDate: Date?
    let categoryId: UUID?
    let tags: [String]
}

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var categoryViewModel: CategoryListViewModel

    @State private var title: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date().addingTimeInterval(3600 * 24)
    @State private var categoryId: UUID?
    @State private var tagInput: String = ""

    let onSubmit: (TodoItemDraft) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("タイトル") {
                    TextField("やることを入力", text: $title)
                        .submitLabel(.done)
                }

                Section("カテゴリ") {
                    Picker("カテゴリ", selection: $categoryId) {
                        Text("なし").tag(UUID?.none)
                        ForEach(categoryViewModel.categories) { category in
                            Text(category.name).tag(UUID?.some(category.id))
                        }
                    }
                }

                Section {
                    TextField("カンマ区切りで入力 (例: 仕事, 急ぎ)", text: $tagInput, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    let parsed = Tag.parse(tagInput)
                    if !parsed.isEmpty {
                        TagChipsView(tags: parsed)
                    }
                } header: {
                    Text("タグ")
                } footer: {
                    Text("自動的に小文字化・前後の空白除去・重複除去を行います。")
                }

                Section("期限") {
                    Toggle("期限を設定する", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker(
                            "期限",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("新しい Todo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("キャンセル", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("追加", action: submit)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func submit() {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let draft = TodoItemDraft(
            title: trimmed,
            dueDate: hasDueDate ? dueDate : nil,
            categoryId: categoryId,
            tags: Tag.parse(tagInput)
        )
        onSubmit(draft)
        dismiss()
    }
}

struct TagChipsView: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    AddTodoView { _ in }
        .environmentObject(CategoryListViewModel(store: InMemoryCategoryStore(items: [
            Category(name: "仕事", colorHex: "#0A84FF"),
            Category(name: "プライベート", colorHex: "#FF9500")
        ])))
}
