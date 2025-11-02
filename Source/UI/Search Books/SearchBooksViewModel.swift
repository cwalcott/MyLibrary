import Combine
import Foundation

@MainActor
final class SearchBooksViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var books: [OpenLibraryBook] = []

    private let openLibraryAPIClient: OpenLibraryAPIClient
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(openLibraryAPIClient: OpenLibraryAPIClient) {
        self.openLibraryAPIClient = openLibraryAPIClient

        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in self?.performSearch(query) }
            .store(in: &cancellables)
    }

    private func performSearch(_ query: String) {
        searchTask?.cancel()

        guard !query.isEmpty else {
            books = []
            return
        }

        searchTask = Task {
            do {
                print("Searching for: \(query)")
                books = try await openLibraryAPIClient.search(query)
            } catch {
                print("Search error: \(error)")
                books = []
            }
        }
    }
}
