import SwiftUI

@main
struct MyLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchBooksScreen(viewModel: SearchBooksViewModel())
            }
        }
    }
}
