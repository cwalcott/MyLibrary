import SwiftUI

struct FavoritesScreen: View {
    @StateObject var viewModel: FavoritesViewModel

    @Environment(\.composer) private var composer

    var body: some View {
        List(viewModel.books) { book in
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
        .navigationTitle("Favorite Books")
        .toolbar {
            NavigationLink {
                SearchBooksScreen(viewModel: composer.makeSearchBooksViewModel())
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        FavoritesScreen(viewModel: composer.makeFavoritesViewModel())
    }
}
