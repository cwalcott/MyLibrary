import Foundation
import GRDB

final class AppDatabase {
    private let dbQueue: DatabaseQueue

    static func fromFile(named name: String) throws -> AppDatabase {
        let databaseURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent(name)

        print("Initializing sqlite database at \(databaseURL.path)")
        return try AppDatabase(
            dbQueue: try DatabaseQueue(path: databaseURL.path)
        )
    }

    init(dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue

        try migrate(dbQueue: dbQueue)
    }

    func books() -> BookDAO {
        return BookDAO(dbQueue: dbQueue)
    }
}

private func migrate(dbQueue: DatabaseQueue) throws {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("v1") { db in
        try db.create(table: "books") { t in
            t.column("authorNames", .text)
            t.column("openLibraryKey", .text).notNull()
            t.column("title", .text).notNull()
            t.column("uuid", .text).notNull().primaryKey()
        }
    }

    try migrator.migrate(dbQueue)
}
