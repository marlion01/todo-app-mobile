import SwiftUI

struct AddTodoView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date().addingTimeInterval(3600 * 24)

    let onSubmit: (_ title: String, _ dueDate: Date?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("タイトル") {
                    TextField("やることを入力", text: $title)
                        .submitLabel(.done)
                        .onSubmit(submit)
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
        onSubmit(trimmed, hasDueDate ? dueDate : nil)
        dismiss()
    }
}

#Preview {
    AddTodoView { _, _ in }
}
