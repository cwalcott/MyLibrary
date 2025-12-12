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

    private var isFavorite = false
    private var openLibraryBook: OpenLibraryBook?

    init(
        database: AppDatabase,
        openLibraryAPIClient: OpenLibraryAPIClient,
        openLibraryKey: String
    ) {
        self.database = database
        self.openLibraryAPIClient = openLibraryAPIClient
        self.openLibraryKey = openLibraryKey

        if database.books().findByOpenLibraryKey(openLibraryKey) != nil {
            isFavorite = true
        }
    }

    func addToFavorites() {
        if let openLibraryBook = self.openLibraryBook, !isFavorite {
            database.books().insert(openLibraryBook.asBook())

            isFavorite = true
            self.state?.isFavorite = true
        }
    }

    func loadBook() async {
        do {
            if let book = try await openLibraryAPIClient.getBook(self.openLibraryKey) {
                self.openLibraryBook = book
                self.state = BookDetailsUIState(
                    authorNames: book.authorName?.joined(separator: ","),
                    isFavorite: isFavorite,
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
        if isFavorite {
            database.books().deleteByOpenLibraryKey(openLibraryKey)

            isFavorite = false
            self.state?.isFavorite = false
        }
    }
}
