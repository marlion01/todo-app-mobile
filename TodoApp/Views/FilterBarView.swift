import SwiftUI

struct FilterBarView: View {
    @EnvironmentObject private var todoViewModel: TodoListViewModel
    @EnvironmentObject private var categoryViewModel: CategoryListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    label: "全て",
                    isSelected: todoViewModel.filter.categoryId == nil,
                    color: .gray
                ) {
                    todoViewModel.setFilter(category: nil)
                }

                ForEach(categoryViewModel.categories) { category in
                    let isSelected = todoViewModel.filter.categoryId == category.id
                    FilterChip(
                        label: category.name,
                        isSelected: isSelected,
                        color: Color(hex: category.colorHex)
                    ) {
                        todoViewModel.setFilter(category: isSelected ? nil : category.id)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct FilterChip: View {
    let label: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected ? color.opacity(0.25) : Color(.systemGray6),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? color : .primary)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let categoryVM = CategoryListViewModel(store: InMemoryCategoryStore(items: [
        Category(name: "仕事", colorHex: "#0A84FF"),
        Category(name: "プライベート", colorHex: "#FF9500")
    ]))
    let todoVM = TodoListViewModel(store: InMemoryTodoStore())
    return FilterBarView()
        .environmentObject(todoVM)
        .environmentObject(categoryVM)
        .padding(.vertical)
}
