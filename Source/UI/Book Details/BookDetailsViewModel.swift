import Combine

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published var book: Book?
    @Published var favoriteState: FavoritesState = .hidden
    @Published var errorMessage: String?
    @Published var loadErrorMessage: String?

    enum FavoritesState { case favorite, notFavorite, hidden }

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
        guard let openLibraryBook, favoriteState == .notFavorite else {
            return
        }

        do {
            try database.books().insert(openLibraryBook.asBook())
            favoriteState = .favorite
        } catch {
            errorMessage = "Failed to add to favorites"
        }
    }

    func loadBook() async {
        do {
            if let book = try await openLibraryAPIClient.getBook(self.openLibraryKey) {
                self.openLibraryBook = book

                if let localBook = database.books().findByOpenLibraryKey(openLibraryKey) {
                    self.book = localBook
                    self.favoriteState = .favorite
                } else {
                    self.book = book.asBook()
                    self.favoriteState = .notFavorite
                }
            } else {
                self.openLibraryBook = nil
                self.book = nil
                self.favoriteState = .hidden
                self.loadErrorMessage = "Book not found"
            }
        } catch {
            print("Failed to fetch book: \(error)")
            self.openLibraryBook = nil

            if let localBook = database.books().findByOpenLibraryKey(openLibraryKey) {
                self.book = localBook
                self.favoriteState = .favorite
            } else {
                self.book = nil
                self.favoriteState = .hidden
                self.loadErrorMessage = "Unable to load book. Check your connection."
            }
        }
    }

    func removeFromFavorites() {
        guard favoriteState == .favorite else {
            return
        }

        do {
            try database.books().deleteByOpenLibraryKey(openLibraryKey)
            favoriteState = .notFavorite
        } catch {
            errorMessage = "Failed to remove from favorites"
        }
    }
}
