import Combine

struct BookDetailsUIState: Equatable {
    var authorNames: String?
    var isFavorite: Bool
    var title: String
}

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published var state: BookDetailsUIState?
    @Published var errorMessage: String?

    private let database: AppDatabase
    private let openLibraryAPIClient: OpenLibraryAPIClient
    private let openLibraryKey: String

    private var openLibraryBook: OpenLibraryBook?

    init(
        database: AppDatabase,
        openLibraryAPIClient: OpenLibraryAPIClient,
        openLibraryKey: String
    ) {
        self.database = database
        self.openLibraryAPIClient = openLibraryAPIClient
        self.openLibraryKey = openLibraryKey
    }

    func addToFavorites() {
        guard let openLibraryBook, let state, !state.isFavorite else {
            return
        }

        do {
            try database.books().insert(openLibraryBook.asBook())
            self.state?.isFavorite = true
        } catch {
            errorMessage = "Failed to add to favorites"
        }
    }

    func loadBook() async {
        do {
            if let book = try await openLibraryAPIClient.getBook(self.openLibraryKey) {
                self.openLibraryBook = book
                self.state = BookDetailsUIState(
                    authorNames: book.authorName?.joined(separator: ","),
                    isFavorite: database.books().findByOpenLibraryKey(openLibraryKey) != nil,
                    title: book.title
                )
            } else {
                self.openLibraryBook = nil
                self.state = nil
            }
        } catch {
            // TODO: improve error handling
            print("Failed to fetch book: \(error)")
            self.openLibraryBook = nil
            self.state = nil
        }
    }

    func removeFromFavorites() {
        guard let state, state.isFavorite else {
            return
        }

        do {
            try database.books().deleteByOpenLibraryKey(openLibraryKey)
            self.state?.isFavorite = false
        } catch {
            errorMessage = "Failed to remove from favorites"
        }
    }
}
