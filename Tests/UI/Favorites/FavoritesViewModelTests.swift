import Combine
import GRDB
import Testing
@testable import MyLibrary

@MainActor
struct FavoritesViewModelTests {
    private let database = try! AppDatabase(dbQueue: try! DatabaseQueue())

    private let books = [
        Book(
            authorNames: "J.R.R. Tolkien",
            openLibraryKey: "/works/OL27482W",
            title: "The Hobbit"
        ),
        Book(
            authorNames: "Frank Herbert",
            openLibraryKey: "/works/OL893415W",
            title: "Dune"
        )
    ]

    @Test func streamsAllBooksAsFavorites() async throws {
        try books.forEach { try database.books().insert($0) }
        let viewModel = createViewModel()
        var booksStream = viewModel.$books.values.makeAsyncIterator()

        #expect(await booksStream.next() == [])
        #expect(await booksStream.next() == books)

        try database.books().deleteByOpenLibraryKey(books[1].openLibraryKey)
        #expect(await booksStream.next() == [books[0]])
    }

    private func createViewModel() -> FavoritesViewModel {
        return FavoritesViewModel(database: database)
    }
}
