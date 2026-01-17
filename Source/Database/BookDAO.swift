import Combine
import GRDB

final class BookDAO {
    let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func deleteByOpenLibraryKey(_ openLibraryKey: String) throws {
        _ = try dbQueue.write { db in
            try Book.filter(Book.Columns.openLibraryKey == openLibraryKey).deleteAll(db)
        }
    }

    func findByOpenLibraryKey(_ openLibraryKey: String) -> Book? {
        return try? dbQueue.read { db in
            try Book.filter(Book.Columns.openLibraryKey == openLibraryKey).fetchOne(db)
        }
    }

    func insert(_ book: Book) throws {
        try dbQueue.write { db in
            try book.insert(db)
        }
    }

    func streamAll() -> some Publisher<[Book], Never> {
        return ValueObservation
            .tracking { db in try Book.order(Book.Columns.title).fetchAll(db) }
            .publisher(in: dbQueue)
            .catch { error -> Just<[Book]> in
                print("Database error in streamAll: \(error)")
                return Just([])
            }
            .removeDuplicates()
    }
}
