import Combine
import CombineSchedulers
import Dispatch
import Testing
@testable import MyLibrary

@MainActor
struct SearchBooksViewModelTests {
    private let openLibraryAPIClient = FakeOpenLibraryAPIClient()
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    @Test func searchBooks() async throws {
        let viewModel = createViewModel()

        viewModel.query = "Tolkien"
        await testScheduler.run()

        guard case let .results(books) = viewModel.results else {
            Issue.record("expected results")
            return
        }
        #expect(books.count == 2)
        #expect(books.allSatisfy { ($0.authorNames ?? "").contains("Tolkien") })
    }

    @Test func searchBooks_error() async {
        let viewModel = createViewModel()

        openLibraryAPIClient.networkErrors = true
        viewModel.query = "Tolkien"
        await testScheduler.run()

        #expect(viewModel.results == .networkError)

        openLibraryAPIClient.networkErrors = false
        viewModel.performSearch(viewModel.query)
        await testScheduler.run()

        #expect(viewModel.results.hasResults)
    }

    @Test func searchBooks_debouncesQuery() async {
        let viewModel = createViewModel()
        #expect(viewModel.results == .empty)

        viewModel.query = "Asimov"
        #expect(viewModel.results == .empty)

        await testScheduler.advance(by: .milliseconds(250))
        #expect(viewModel.results == .empty)

        await testScheduler.advance(by: .milliseconds(500))
        #expect(viewModel.results.hasResults)
    }

    private func createViewModel() -> SearchBooksViewModel {
        return SearchBooksViewModel(
            openLibraryAPIClient: openLibraryAPIClient,
            mainScheduler: testScheduler.eraseToAnyScheduler()
        )
    }
}

private extension SearchBooksViewModel.ResultsState {
    var hasResults: Bool {
        if case .results = self {
            return true
        } else {
            return false
        }
    }
}
