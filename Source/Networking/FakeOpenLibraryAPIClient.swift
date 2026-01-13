

final class FakeOpenLibraryAPIClient: OpenLibraryAPIClient {
    var networkDelay: Duration?
    var networkErrors = false

    func getBook(_ key: String) async throws -> OpenLibraryBook? {
        if networkErrors {
            throw APIError.invalidResponse
        } else if let networkDelay {
            try await Task.sleep(for: networkDelay)
        }

        return MOCK_BOOKS.first(where: { $0.key == key })
    }

    func search(_ query: String) async throws -> [OpenLibraryBook] {
        if networkErrors {
            throw APIError.invalidResponse
        } else if let networkDelay {
            try await Task.sleep(for: networkDelay)
        }

        guard !query.isEmpty else {
            return MOCK_BOOKS
        }

        return MOCK_BOOKS.filter { book in
            book.title.contains(query) ||
                (book.authorName ?? []).contains(where: { $0.contains(query) })
        }
    }
}

let MOCK_BOOKS = [
    OpenLibraryBook(
        authorName: ["J.R.R. Tolkien"],
        coverEditionKey: "OL51711263M",
        key: "/works/OL27482W",
        title: "The Hobbit"
    ),
    OpenLibraryBook(
        authorName: ["J.R.R. Tolkien"],
        coverEditionKey: "OL51708686M",
        key: "/works/OL27513W",
        title: "The Fellowship of the Ring"
    ),
    OpenLibraryBook(
        authorName: ["Isaac Asimov"],
        coverEditionKey: "OL51565403M",
        key: "/works/OL46125W",
        title: "Foundation"
    ),
    OpenLibraryBook(
        authorName: ["Frank Herbert"],
        key: "/works/OL893415W",
        title: "Dune"
    ),
]
