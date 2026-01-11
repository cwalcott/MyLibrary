import Combine
import CombineSchedulers
import Dispatch
import Testing
@testable import MyLibrary

@MainActor
struct SearchBooksViewModelTests {
    private let openLibraryAPIClient = FakeOpenLibraryAPIClient()
    private let testScheduler: TestSchedulerOf<DispatchQueue> = DispatchQueue.test

    @Test func searchBooks() async {
        let viewModel = createViewModel()

        viewModel.searchQuery = "Tolkien"
        await testScheduler.run()

        #expect(viewModel.books.count == 2)
        #expect(viewModel.books.allSatisfy { ($0.authorName?.first ?? "").contains("Tolkien") })
    }

    @Test func searchBooks_error() async {
        let viewModel = createViewModel()

        openLibraryAPIClient.networkErrors = true
        viewModel.searchQuery = "Tolkien"
        await testScheduler.run()

        #expect(viewModel.books.isEmpty)
        #expect(viewModel.errorMessage != nil)

        openLibraryAPIClient.networkErrors = false
        viewModel.performSearch(viewModel.searchQuery)
        await testScheduler.run()

        #expect(viewModel.books.count == 2)
    }

    @Test func searchBooks_debouncesQuery() async {
        let viewModel = createViewModel()
        #expect(viewModel.books.isEmpty)

        viewModel.searchQuery = "Asimov"
        #expect(viewModel.books.isEmpty)

        await testScheduler.advance(by: .milliseconds(250))
        #expect(viewModel.books.isEmpty)

        await testScheduler.advance(by: .milliseconds(500))
        #expect(viewModel.books.count == 1)
    }

    private func createViewModel() -> SearchBooksViewModel {
        return SearchBooksViewModel(
            openLibraryAPIClient: openLibraryAPIClient,
            mainScheduler: testScheduler.eraseToAnyScheduler()
        )
    }
}
