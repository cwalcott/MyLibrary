import SwiftUI

struct SearchBooksScreen: View {
    @StateObject var viewModel: SearchBooksViewModel

    @Environment(\.composer) private var composer

    @State private var searchIsActive = true

    var body: some View {
        Group {
            if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text(errorMessage)
                        .foregroundStyle(.secondary)

                    Button("Retry") {
                        viewModel.performSearch(viewModel.searchQuery)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
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

#Preview("Network Error") {
    let composer = Composer.preview {
        ($0.openLibraryAPIClient as! FakeOpenLibraryAPIClient).networkErrors = true
    }

    NavigationStack {
        SearchBooksScreen(viewModel: composer.makeSearchBooksViewModel())
            .environment(\.composer, composer)
    }
}
