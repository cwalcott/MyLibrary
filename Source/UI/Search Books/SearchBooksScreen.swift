import SwiftUI

struct SearchBooksScreen: View {
    @StateObject var viewModel: SearchBooksViewModel
    @State private var searchIsActive = true

    var body: some View {
        List(viewModel.books) { book in
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                if let author = book.authorName?.first {
                    Text(author)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Books")
        .searchable(text: $viewModel.searchQuery, isPresented: $searchIsActive)
    }
}

#Preview {
    @Previewable @Environment(\.composer) var composer

    NavigationView {
        SearchBooksScreen(
            viewModel: SearchBooksViewModel(
                openLibraryAPIClient: composer.makeOpenLibraryAPIClient()
            )
        )
    }
}
