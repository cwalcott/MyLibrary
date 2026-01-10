import GRDB

extension Book: FetchableRecord, PersistableRecord {
    static let databaseTableName = "books"

    enum Columns: String, ColumnExpression {
        case openLibraryKey
    }
}
