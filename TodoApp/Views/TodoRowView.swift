import SwiftUI

struct TodoRowView: View {
    @EnvironmentObject private var categoryViewModel: CategoryListViewModel

    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCompleted ? Color.accentColor : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(item.isCompleted ? "完了を取り消す" : "完了にする")

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .strikethrough(item.isCompleted, color: .secondary)
                    .foregroundStyle(item.isCompleted ? .secondary : .primary)

                if hasMetaRow {
                    HStack(spacing: 8) {
                        if let category = categoryViewModel.category(with: item.categoryId) {
                            CategoryBadgeView(category: category)
                        }
                        if let dueDate = item.dueDate {
                            Label {
                                Text(dueDate, style: .date)
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                }

                if !item.tags.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }

    private var hasMetaRow: Bool {
        item.categoryId != nil || item.dueDate != nil
    }
}

#Preview {
    let category = Category(name: "仕事", colorHex: "#0A84FF")
    let categoryVM = CategoryListViewModel(store: InMemoryCategoryStore(items: [category]))
    return List {
        TodoRowView(item: TodoItem(title: "未完了タスク")) {}
        TodoRowView(item: TodoItem(title: "完了タスク", isCompleted: true)) {}
        TodoRowView(item: TodoItem(
            title: "全部入り",
            dueDate: Date(),
            categoryId: category.id,
            tags: ["urgent", "review"]
        )) {}
    }
    .environmentObject(categoryVM)
}
