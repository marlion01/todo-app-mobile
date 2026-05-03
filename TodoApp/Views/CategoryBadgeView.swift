import SwiftUI

struct CategoryBadgeView: View {
    let category: Category

    var body: some View {
        let color = Color(hex: category.colorHex)
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(category.name)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color.opacity(0.15), in: Capsule())
        .foregroundStyle(color)
    }
}

#Preview {
    VStack(spacing: 8) {
        CategoryBadgeView(category: Category(name: "仕事", colorHex: "#0A84FF"))
        CategoryBadgeView(category: Category(name: "プライベート", colorHex: "#FF9500"))
    }
    .padding()
}
