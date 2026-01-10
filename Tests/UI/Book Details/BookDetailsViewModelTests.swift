import GRDB
import Testing
@testable import MyLibrary

@MainActor
struct BookDetailsViewModelTests {
    private let database = try! AppDatabase(dbQueue: try! DatabaseQueue())
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

    @Test func loadBook_favorite() async throws {
        database.books().insert(book)
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

    @Test func removeFromFavorites() async {
        database.books().insert(book)
        let viewModel = createViewModel(openLibraryKey: book.openLibraryKey)
        await viewModel.loadBook()

        viewModel.removeFromFavorites()

        #expect(database.books().findByOpenLibraryKey(book.openLibraryKey) == nil)
        #expect(viewModel.state?.isFavorite == false)
    }

    private func createViewModel(openLibraryKey: String) -> BookDetailsViewModel {
        return BookDetailsViewModel(
            database: database,
            openLibraryAPIClient: openLibraryAPIClient,
            openLibraryKey: openLibraryKey
        )
    }
}
