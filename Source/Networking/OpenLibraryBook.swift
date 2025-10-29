struct OpenLibraryBook: Decodable, Equatable, Identifiable {
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
}
