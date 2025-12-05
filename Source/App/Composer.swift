import CombineSchedulers
import Foundation
import SwiftUI

class Composer {
    static let live: Composer = Composer(
        openLibraryAPIClient: LiveOpenLibraryAPIClient(urlSession: .shared)
    )

    static let preview: Composer = Composer(openLibraryAPIClient: FakeOpenLibraryAPIClient())

    let openLibraryAPIClient: OpenLibraryAPIClient

    init(openLibraryAPIClient: OpenLibraryAPIClient) {
        self.openLibraryAPIClient = openLibraryAPIClient
    }

    @MainActor
    func makeBookDetailsViewModel(openLibraryKey: String) -> BookDetailsViewModel {
        return BookDetailsViewModel(
            openLibraryAPIClient: openLibraryAPIClient, openLibraryKey: openLibraryKey
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
