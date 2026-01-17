import Combine
import CombineSchedulers
import Foundation

@MainActor
final class SearchBooksViewModel: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var lastQuery: String = ""
    @Published var books: [Book] = []
    @Published var errorMessage: String?

    var noResultsFound: Bool {
        books.isEmpty && !searchQuery.isEmpty && lastQuery == searchQuery
    }

    private let openLibraryAPIClient: OpenLibraryAPIClient
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(
        openLibraryAPIClient: OpenLibraryAPIClient,
        mainScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.openLibraryAPIClient = openLibraryAPIClient

        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: mainScheduler)
            .removeDuplicates()
            .sink { [weak self] query in self?.performSearch(query) }
            .store(in: &cancellables)
    }

    func performSearch(_ query: String) {
        searchTask?.cancel()
        errorMessage = nil

        guard query.count > 2 else {
            books = []
            return
        }

        searchTask = Task {
            do {
                books = try await openLibraryAPIClient.search(query).map { $0.asBook() }
                lastQuery = query
            } catch {
                print("Search error: \(error)")
                errorMessage = "Unable to search. Check your connection."
                books = []
            }
        }
    }
}
