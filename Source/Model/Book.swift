import Foundation

struct Book: Codable, Equatable, Identifiable {
    var authorNames: String?
    var coverEditionKey: String?
    var openLibraryKey: String
    var title: String
    var uuid = UUID()

    var id: UUID {
        uuid
    }
}

extension Book {
    var coverImageURL: URL? {
        guard let coverEditionKey else {
            return nil
        }

        return URL(string: "https://covers.openlibrary.org/b/olid/\(coverEditionKey)-M.jpg")
    }
}
