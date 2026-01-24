import SwiftUI

struct SearchBooksScreen: View {
    @StateObject var viewModel: SearchBooksViewModel

    @Environment(\.composer) private var composer

    @State private var searchIsActive = true

    var body: some View {
        Group {
            switch viewModel.results {
            case .empty:
                EmptyView()

            case .networkError:
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)

                    Text("Unable to search. Check your connection.")
                        .foregroundStyle(.secondary)

                    Button("Retry") {
                        viewModel.performSearch(viewModel.query)
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding()

            case .noResults:
                ContentUnavailableView.search(text: viewModel.query)

            case .results(let books):
                List(books) { book in
                    NavigationLink {
                        BookDetailsScreen(
                            viewModel: composer.makeBookDetailsViewModel(
                                openLibraryKey: book.openLibraryKey
                            )
                        )
                    } label: {
                        HStack {
                            AsyncImage(url: book.coverImageURL) { image in
                                image.resizable().aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 50, height: 50)

                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)

                                if let authors = book.authorNames {
                                    Text(authors)
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Search Books")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.query, isPresented: $searchIsActive)
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
