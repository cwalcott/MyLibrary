import GRDB
import SwiftUI

struct BookDetailsScreen: View {
    @StateObject var viewModel: BookDetailsViewModel

    var body: some View {
        ZStack {
            if let book = viewModel.book {
                bookContent(book, favoriteState: viewModel.favoriteState)
            } else {
                if let loadErrorMessage = viewModel.loadErrorMessage {
                    loadErrorScreen(loadErrorMessage)
                } else {
                    bookContent(
                        Book(authorNames: "Placeholder", openLibraryKey: "", title: "Placeholder"),
                        favoriteState: .hidden
                    )
                    .redacted(reason: .placeholder)
                }
            }
        }
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: .constant(viewModel.errorMessage != nil)
        ) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }
        .task {
            await viewModel.loadBook()
        }
    }

    @ViewBuilder
    private func bookContent(
        _ book: Book,
        favoriteState: BookDetailsViewModel.FavoritesState
    ) -> some View {
        ZStack {
            VStack {
                AsyncImage(url: book.coverImageURL) { image in
                    image.resizable().aspectRatio(contentMode: .fit)
                } placeholder: {
                    Color.gray.opacity(0.5)
                }
                .frame(maxWidth: 200, maxHeight: 300)

                Text(book.title)
                    .font(.largeTitle)

                if let authorNames = book.authorNames {
                    Text(authorNames)
                        .font(.subheadline.italic())
                }
            }

            Group {
                switch favoriteState {
                case .favorite:
                    Button("Remove from Favorites") {
                        viewModel.removeFromFavorites()
                    }
                    .buttonStyle(.borderedProminent)

                case .notFavorite:
                    Button("Add to Favorites") {
                        viewModel.addToFavorites()
                    }
                    .buttonStyle(.borderedProminent)

                case .hidden:
                    EmptyView()
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func loadErrorScreen(_ error: String) -> some View {
        ContentUnavailableView {
            Label("Unable to load book", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error)
        } actions: {
            Button("Retry") {
                Task {
                    await viewModel.loadBook()
                }
            }
        }
    }
}

#Preview("Favorite") {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27482W")
        )
    }
}

#Preview("Not favorite") {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
    }
}

#Preview("Slow connection") {
    let composer = Composer.preview {
        ($0.openLibraryAPIClient as! FakeOpenLibraryAPIClient).networkDelay = .seconds(30)
    }

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
    }
}

#Preview("DB Error") {
    let composer = Composer.preview {
        try! $0.database.dbQueue.write { db in
            try db.execute(sql: "DROP TABLE books")
        }
    }

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
        .environment(\.composer, composer)
    }
}

#Preview("Network Error (locally saved)") {
    let composer = Composer.preview {
        ($0.openLibraryAPIClient as! FakeOpenLibraryAPIClient).networkErrors = true
    }

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27482W")
        )
        .environment(\.composer, composer)
    }
}

#Preview("Network Error (no local data)") {
    let composer = Composer.preview {
        ($0.openLibraryAPIClient as! FakeOpenLibraryAPIClient).networkErrors = true
    }

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
        .environment(\.composer, composer)
    }
}
