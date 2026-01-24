import Combine
import CombineSchedulers
import Foundation

@MainActor
final class SearchBooksViewModel: ObservableObject {
    enum ResultsState: Equatable {
        case empty, networkError, results([Book]), noResults
    }

    @Published var query: String = ""
    @Published var results: ResultsState = .empty

    private let openLibraryAPIClient: OpenLibraryAPIClient
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    init(
        openLibraryAPIClient: OpenLibraryAPIClient,
        mainScheduler: AnySchedulerOf<DispatchQueue>
    ) {
        self.openLibraryAPIClient = openLibraryAPIClient

        $query
            .debounce(for: .seconds(0.5), scheduler: mainScheduler)
            .removeDuplicates()
            .sink { [weak self] query in self?.performSearch(query) }
            .store(in: &cancellables)
    }

    func performSearch(_ query: String) {
        searchTask?.cancel()

        guard query.count > 2 else {
            results = .empty
            return
        }

        searchTask = Task {
            do {
                let books = try await openLibraryAPIClient.search(query).map { $0.asBook() }
                if books.isEmpty {
                    results = .noResults
                } else {
                    results = .results(books)
                }
            } catch {
                print("Search error: \(error)")
                results = .networkError
            }
        }
    }
}
