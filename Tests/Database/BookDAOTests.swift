import GRDB
import Testing
@testable import MyLibrary

struct BookDAOTests {
    private let dbQueue: DatabaseQueue
    private let database: AppDatabase
    private let bookDao: BookDAO

    private let book = Book(
        authorNames: "J.R.R. Tolkien",
        openLibraryKey: "/works/OL27482W",
        title: "The Hobbit"
    )

    init() throws {
        dbQueue = try DatabaseQueue()
        database = try AppDatabase(dbQueue: dbQueue)
        bookDao = database.books()
    }

    @Test func deleteByOpenLibraryKey() throws {
        try dbQueue.write { db in
            try book.insert(db)
        }

        bookDao.deleteByOpenLibraryKey(book.openLibraryKey)

        try dbQueue.read { db in
            try #expect(Book.fetchOne(db, key: book.uuid) == nil)
        }
    }

    @Test func findByOpenLibraryKey() throws {
        try dbQueue.write { db in
            try book.insert(db)
        }

        #expect(bookDao.findByOpenLibraryKey(book.openLibraryKey) == book)
        #expect(bookDao.findByOpenLibraryKey("unknown") == nil)
    }

    @Test func insert() throws {
        bookDao.insert(book)

        try dbQueue.read { db in
            try #expect(Book.fetchOne(db, key: book.uuid) == book)
        }
    }
}
