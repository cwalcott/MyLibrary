import SwiftUI

@main
struct MyLibraryApp: App {
    @Environment(\.composer) private var composer

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SearchBooksScreen(
                    viewModel: SearchBooksViewModel(
                        openLibraryAPIClient: composer.openLibraryAPIClient
                    )
                )
            }
        }
    }
}
