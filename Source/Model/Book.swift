import Foundation

struct Book: Codable, Equatable, Identifiable {
    var authorNames: String?
    var openLibraryKey: String
    var title: String
    var uuid = UUID()

    var id: UUID {
        uuid
    }
}
