import GRDB
import Testing
@testable import MyLibrary

@MainActor
struct BookDetailsViewModelTests {
    private var database = try! AppDatabase(dbQueue: try! DatabaseQueue())
    private let openLibraryAPIClient = FakeOpenLibraryAPIClient()

    private let book = Book(
        authorNames: "J.R.R. Tolkien",
        openLibraryKey: "/works/OL27482W",
        title: "The Hobbit"
    )

    @Test func addToFavorites() async {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()

        viewModel.addToFavorites()

        #expect(database.books().findByOpenLibraryKey(book.openLibraryKey) != nil)
        #expect(viewModel.state?.isFavorite == true)
    }

    @Test func addToFavorites_dbError() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()
        try await database.dbQueue.write { db in
            try db.execute(sql: "DROP TABLE books")
        }

        viewModel.addToFavorites()

        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.state?.isFavorite != true)
    }

    @Test func loadBook_notFavorite() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)

        await viewModel.loadBook()

        #expect(
            viewModel.state == BookDetailsUIState(
                authorNames: book.authorNames,
                isFavorite: false,
                title: book.title
            )
        )
    }

    @Test func loadBook_notFavorite_networkError() async throws {
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        openLibraryAPIClient.networkErrors = true

        await viewModel.loadBook()

        #expect(viewModel.state == nil)
        #expect(viewModel.loadErrorMessage != nil)
    }

    @Test func loadBook_favorite() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)

        await viewModel.loadBook()

        #expect(
            viewModel.state == BookDetailsUIState(
                authorNames: book.authorNames,
                isFavorite: true,
                title: book.title
            )
        )
    }

    @Test func loadBook_favorite_networkError() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        openLibraryAPIClient.networkErrors = true

        await viewModel.loadBook()

        #expect(
            viewModel.state == BookDetailsUIState(
                authorNames: book.authorNames,
                isFavorite: true,
                title: book.title
            )
        )
        #expect(viewModel.loadErrorMessage != nil)
    }

    @Test func removeFromFavorites() async throws {
        try database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()

        viewModel.removeFromFavorites()

        #expect(database.books().findByOpenLibraryKey(book.openLibraryKey) == nil)
        #expect(viewModel.state?.isFavorite == false)
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
        #expect(viewModel.state?.isFavorite == true)
    }

    private func createViewModel(openLibraryKey: String) -> BookDetailsViewModel {
        return BookDetailsViewModel(
            database: database,
            openLibraryAPIClient: openLibraryAPIClient,
            openLibraryKey: openLibraryKey
        )
    }
}
