import Combine

struct BookDetailsUIState: Equatable {
    var authorNames: String?
    var isFavorite: Bool
    var title: String
}

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published var state: BookDetailsUIState?

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
        if let openLibraryBook, let state, !state.isFavorite {
            database.books().insert(openLibraryBook.asBook())

            self.state?.isFavorite = true
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
            print("Failed to fetch book: 1\(error)")
            self.openLibraryBook = nil
            self.state = nil
        }
    }

    func removeFromFavorites() {
        if let state, state.isFavorite {
            database.books().deleteByOpenLibraryKey(openLibraryKey)

            self.state?.isFavorite = false
        }
    }
}
