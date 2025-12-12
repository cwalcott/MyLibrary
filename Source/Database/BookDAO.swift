import GRDB

final class BookDAO {
    let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func deleteByOpenLibraryKey(_ openLibraryKey: String) {
        _ = try! dbQueue.write { db in
            try Book.filter(Book.Columns.openLibraryKey == openLibraryKey).deleteAll(db)
        }
    }

    func findByOpenLibraryKey(_ openLibraryKey: String) -> Book? {
        return try? dbQueue.read { db in
            try Book.filter(Book.Columns.openLibraryKey == openLibraryKey).fetchOne(db)
        }
    }

    func insert(_ book: Book) {
        try! dbQueue.write { db in
            try book.insert(db)
        }
    }
}
