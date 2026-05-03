import SwiftUI

struct CategoryManagementView: View {
    @EnvironmentObject private var viewModel: CategoryListViewModel

    @State private var newName: String = ""
    @State private var selectedColor: String = Category.defaultColor

    var body: some View {
        Form {
            Section("新規カテゴリ") {
                TextField("カテゴリ名", text: $newName)
                ColorPickerRow(selection: $selectedColor)
                Button("追加") {
                    if viewModel.add(name: newName, colorHex: selectedColor) != nil {
                        newName = ""
                        selectedColor = Category.defaultColor
                    }
                }
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Section("既存のカテゴリ") {
                if viewModel.categories.isEmpty {
                    Text("カテゴリはまだありません")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.categories) { category in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: category.colorHex))
                                .frame(width: 14, height: 14)
                            Text(category.name)
                            Spacer()
                        }
                    }
                    .onDelete(perform: viewModel.delete)
                }
            }
        }
        .navigationTitle("カテゴリ管理")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ColorPickerRow: View {
    @Binding var selection: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Category.presetColors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selection == hex ? 2 : 0)
                        )
                        .onTapGesture { selection = hex }
                        .accessibilityLabel("カラー \(hex)")
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
            .environmentObject(CategoryListViewModel(store: InMemoryCategoryStore(items: [
                Category(name: "仕事", colorHex: "#0A84FF"),
                Category(name: "買い物", colorHex: "#34C759")
            ])))
    }
}
