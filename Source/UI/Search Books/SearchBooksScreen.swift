import SwiftUI

struct SearchBooksScreen: View {
    @StateObject var viewModel: SearchBooksViewModel

    @Environment(\.composer) private var composer

    @State private var searchIsActive = true

    var body: some View {
        List(viewModel.books) { book in
            NavigationLink {
                BookDetailsScreen(
                    viewModel: composer.makeBookDetailsViewModel(openLibraryKey: book.key)
                )
            } label: {
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.headline)

                    if let author = book.authorName?.first {
                        Text(author)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("Search Books")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchQuery, isPresented: $searchIsActive)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
    }
}

#Preview {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        SearchBooksScreen(viewModel: composer.makeSearchBooksViewModel())
    }
}
