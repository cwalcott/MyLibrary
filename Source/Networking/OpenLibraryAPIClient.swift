import Foundation

protocol OpenLibraryAPIClient {
    func getBook(_ key: String) async throws -> OpenLibraryBook?
    func search(_ query: String) async throws -> [OpenLibraryBook]
}

struct OpenLibraryBook: Codable, Equatable, Identifiable {
    var authorName: [String]?
    var coverEditionKey: String?
    var key: String
    var title: String

    var id: String {
        key
    }

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case coverEditionKey = "cover_edition_key"
        case key
        case title
    }

    func asBook() -> Book {
        return Book(
            authorNames: authorName?.joined(separator: ", "),
            openLibraryKey: key,
            title: title
        )
    }
}
