import Combine

@MainActor
final class BookDetailsViewModel: ObservableObject {
    @Published var book: OpenLibraryBook?

    private let openLibraryAPIClient: OpenLibraryAPIClient
    private let openLibraryKey: String

    init(openLibraryAPIClient: OpenLibraryAPIClient, openLibraryKey: String) {
        self.openLibraryAPIClient = openLibraryAPIClient
        self.openLibraryKey = openLibraryKey
    }

    func loadBook() async {
        do {
            self.book = try await openLibraryAPIClient.getBook(self.openLibraryKey)
        } catch {
            // TODO: improve error handling
            print("Failed to fetch book: \(error)")
        }
    }
}
