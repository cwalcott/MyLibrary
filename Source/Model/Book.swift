import Foundation
import GRDB

struct Book: Codable, Identifiable, FetchableRecord, PersistableRecord {
    var author: String?
    var openLibraryKey: String
    var title: String
    var uuid = UUID()

    var id: UUID {
        uuid
    }
}
