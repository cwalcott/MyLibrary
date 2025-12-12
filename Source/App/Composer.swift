import CombineSchedulers
import Foundation
import GRDB
import SwiftUI

class Composer {
    static let live: Composer = {
        return Composer(
            database: try! AppDatabase.fromFile(named: "db.sqlite"),
            openLibraryAPIClient: LiveOpenLibraryAPIClient(urlSession: .shared)
        )
    }()

    static let preview: Composer = {
        let database = try! AppDatabase(dbQueue: DatabaseQueue())
        database.books().insert(MOCK_BOOKS[0].asBook())

        return Composer(
            database: database,
            openLibraryAPIClient: FakeOpenLibraryAPIClient()
        )
    }()

    let database: AppDatabase
    let openLibraryAPIClient: OpenLibraryAPIClient

    init(database: AppDatabase, openLibraryAPIClient: OpenLibraryAPIClient) {
        self.database = database
        self.openLibraryAPIClient = openLibraryAPIClient
    }

    @MainActor
    func makeBookDetailsViewModel(openLibraryKey: String) -> BookDetailsViewModel {
        return BookDetailsViewModel(
            database: database,
            openLibraryAPIClient: openLibraryAPIClient,
            openLibraryKey: openLibraryKey
        )
    }

    @MainActor
    func makeFavoritesViewModel() -> FavoritesViewModel {
        return FavoritesViewModel()
    }

    @MainActor
    func makeSearchBooksViewModel() -> SearchBooksViewModel {
        return SearchBooksViewModel(
            openLibraryAPIClient: openLibraryAPIClient, mainScheduler: .main
        )
    }
}

extension EnvironmentValues {
    @Entry var composer: Composer = {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return .preview
        } else {
            return .live
        }
    }()
}
