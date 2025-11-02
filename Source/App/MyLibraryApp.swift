import SwiftUI

@main
struct MyLibraryApp: App {
    @Environment(\.composer) private var composer

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchBooksScreen(viewModel: composer.makeSearchBooksViewModel())
            }
        }
    }
}
