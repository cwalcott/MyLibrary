import Foundation
import SwiftUI

class Composer {
    let urlSession: URLSession

    static let live: Composer = Composer(urlSession: .shared)

    static let preview: Composer = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return Composer(urlSession: .init(configuration: configuration))
    }()

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func makeOpenLibraryAPIClient() -> OpenLibraryAPIClient {
        return OpenLibraryAPIClient(urlSession: urlSession)
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
