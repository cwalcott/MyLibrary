import GRDB
import Testing
@testable import MyLibrary

@MainActor
struct BookDetailsViewModelTests {
    private var database = try! AppDatabase(dbQueue: try! DatabaseQueue())
    private let openLibraryAPIClient = FakeOpenLibraryAPIClient()

    private let book = Book(
        authorNames: "J.R.R. Tolkien",
        coverEditionKey: "OL51711263M",
        openLibraryKey: "/works/OL27482W",
        title: "The Hobbit"
    )

    @Test func addToFavorites() async {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()

        viewModel.addToFavorites()

        #expect(database.books().findByOpenLibraryKey(book.openLibraryKey) != nil)
        #expect(viewModel.favoriteState == .favorite)
    }

    @Test func addToFavorites_dbError() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()
        try await database.dbQueue.write { db in
            try db.execute(sql: "DROP TABLE books")
        }

        viewModel.addToFavorites()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.favoriteState == .notFavorite)
    }

    @Test func loadBook_notFavorite() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)

        await viewModel.loadBook()

        #expect(viewModel.book?.openLibraryKey == book.openLibraryKey)
        #expect(viewModel.favoriteState == .notFavorite)
    }

    @Test func loadBook_notFavorite_networkError() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        openLibraryAPIClient.networkErrors = true

        await viewModel.loadBook()

        #expect(viewModel.book == nil)
        #expect(viewModel.favoriteState == .hidden)
        #expect(viewModel.loadErrorMessage != nil)
    }

    @Test func loadBook_favorite() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)

        await viewModel.loadBook()

        #expect(viewModel.book == book)
        #expect(viewModel.favoriteState == .favorite)
    }

    @Test func loadBook_favorite_networkError() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        openLibraryAPIClient.networkErrors = true

        await viewModel.loadBook()

        #expect(viewModel.book == book)
        #expect(viewModel.favoriteState == .favorite)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.loadErrorMessage == nil)
    }

    @Test func removeFromFavorites() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()

        viewModel.removeFromFavorites()

        #expect(database.books().findByOpenLibraryKey(book.openLibraryKey) == nil)
        #expect(viewModel.favoriteState == .notFavorite)
    }

    @Test func removeFromFavorites_dbError() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()
        try await database.dbQueue.write { db in
            try db.execute(sql: "DROP TABLE books")
        }

        viewModel.removeFromFavorites()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.favoriteState == .favorite)
    }

    private func createViewModel(openLibraryKey: String) -> BookDetailsViewModel {
        return BookDetailsViewModel(
            database: database,
            openLibraryAPIClient: openLibraryAPIClient,
            openLibraryKey: openLibraryKey
        )
    }
}
