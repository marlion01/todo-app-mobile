import SwiftUI

@main
struct TodoAppApp: App {
    @StateObject private var viewModel = TodoListViewModel(
        store: UserDefaultsTodoStore()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
