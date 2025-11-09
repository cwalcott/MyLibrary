import Foundation
import GRDB

struct Book: Codable, FetchableRecord, PersistableRecord {
    var author: String?
    var openLibraryKey: String
    var title: String
    var uuid = UUID()
}
