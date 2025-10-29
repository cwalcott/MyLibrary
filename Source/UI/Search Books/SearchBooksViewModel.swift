import Combine

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

@MainActor
final class SearchBooksViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var books: [OpenLibraryBook] = MOCK_BOOKS

    init() {
        $searchQuery
            .removeDuplicates()
            .map { query in
                guard !query.isEmpty else { return MOCK_BOOKS }

                return MOCK_BOOKS.filter { book in
                    book.title.contains(query) ||
                        (book.authorName ?? []).contains(where: { $0.contains(query) })
                }
            }
            .assign(to: &$books)
    }
}
