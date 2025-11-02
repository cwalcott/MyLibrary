import Foundation
import SwiftUI

class Composer {
    let openLibraryAPIClient: OpenLibraryAPIClient

    init(openLibraryAPIClient: OpenLibraryAPIClient) {
        self.openLibraryAPIClient = openLibraryAPIClient
    }

    static let live: Composer = Composer(
        openLibraryAPIClient: LiveOpenLibraryAPIClient(urlSession: .shared)
    )

    static let preview: Composer = Composer(openLibraryAPIClient: FakeOpenLibraryAPIClient())
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
