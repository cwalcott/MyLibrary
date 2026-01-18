import Combine

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published var book: Book?
    @Published var favoriteState: FavoritesState = .hidden
    @Published var errorMessage: String?

    enum FavoritesState { case favorite, notFavorite, hidden }

    private let database: AppDatabase
    private let openLibraryAPIClient: OpenLibraryAPIClient
    private let openLibraryKey: String

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
        guard let book, favoriteState == .notFavorite else {
            return
        }

        do {
            try database.books().insert(book)
            favoriteState = .favorite
        } catch {
            errorMessage = "Failed to add to favorites"
        }
    }

    func loadBook() async {
        self.errorMessage = nil

        if let localBook = database.books().findByOpenLibraryKey(openLibraryKey) {
            self.book = localBook
            self.favoriteState = .favorite
            return
        }

        do {
            if let openLibraryBook = try await openLibraryAPIClient.getBook(self.openLibraryKey) {
                self.book = openLibraryBook.asBook()
                self.favoriteState = .notFavorite
            } else {
                self.book = nil
                self.favoriteState = .hidden
                self.errorMessage = "Book not found"
            }
        } catch {
            print("Failed to fetch book: \(error)")
            self.book = nil
            self.favoriteState = .hidden
            self.errorMessage = "Unable to load book. Check your connection."
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
