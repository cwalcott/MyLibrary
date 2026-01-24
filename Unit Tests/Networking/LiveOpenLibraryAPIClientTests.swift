import Foundation
import Testing
@testable import MyLibrary

@MainActor
@Suite(.serialized)
struct OpenLibraryAPIClientTests {
    private let client: OpenLibraryAPIClient
    private let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        urlSession = URLSession(configuration: config)
        client = LiveOpenLibraryAPIClient(urlSession: urlSession)
    }

    @Test func getBookSuccess() async throws {
        let mockJSON = """
        {
            "docs": [
                {
                    "key": "/works/OL45804W",
                    "title": "Dune",
                    "author_name": ["Frank Herbert"],
                    "cover_edition_key": "OL123"
                }
            ]
        }
        """
        MockURLProtocol.mockResponseData = mockJSON.data(using: .utf8)
        MockURLProtocol.mockStatusCode = 200

        let result = try await client.getBook("/works/OL45804W")

        #expect(
            result == OpenLibraryBook(
                authorName: ["Frank Herbert"],
                coverEditionKey: "OL123",
                key: "/works/OL45804W",
                title: "Dune"
            )
        )
    }

    @Test func getBookNotFound() async throws {
        let mockJSON = """
        {
            "docs": []
        }
        """
        MockURLProtocol.mockResponseData = mockJSON.data(using: .utf8)
        MockURLProtocol.mockStatusCode = 200

        let result = try await client.getBook("/works/OL45804W")

        #expect(result == nil)
    }

    @Test func getBookHTTPError() async throws {
        MockURLProtocol.mockResponseData = Data()
        MockURLProtocol.mockStatusCode = 500

        await #expect(throws: APIError.httpError(statusCode: 500)) {
            _ = try await client.getBook("/works/OL45804W")
        }
    }

    @Test func searchSuccess() async throws {
        let mockJSON = """
        {
            "docs": [
                {
                    "key": "/works/OL45804W",
                    "title": "Dune",
                    "author_name": ["Frank Herbert"],
                    "cover_edition_key": "OL123"
                }
            ]
        }
        """
        MockURLProtocol.mockResponseData = mockJSON.data(using: .utf8)
        MockURLProtocol.mockStatusCode = 200

        let results = try await client.search("Dune")

        #expect(
            results == [
                OpenLibraryBook(
                    authorName: ["Frank Herbert"],
                    coverEditionKey: "OL123",
                    key: "/works/OL45804W",
                    title: "Dune"
                )
            ]
        )
    }

    @Test func searchHTTPError() async throws {
        MockURLProtocol.mockResponseData = Data()
        MockURLProtocol.mockStatusCode = 500

        await #expect(throws: APIError.httpError(statusCode: 500)) {
            _ = try await client.search("test")
        }
    }
}
