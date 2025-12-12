import Foundation
import GRDB

struct Book: Codable, Identifiable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "books"

    enum Columns: String, ColumnExpression {
        case openLibraryKey
    }

    var authorNames: String?
    var openLibraryKey: String
    var title: String
    var uuid = UUID()

    var id: UUID {
        uuid
    }
}
