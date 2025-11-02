import Foundation

enum APIError: Equatable, Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
}

final class LiveOpenLibraryAPIClient: OpenLibraryAPIClient {
    private let urlSession: URLSession

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    func search(_ query: String) async throws -> [OpenLibraryBook] {
        guard var components = URLComponents(string: "https://openlibrary.org/search.json") else {
            throw APIError.invalidURL
        }

        components.queryItems = [URLQueryItem(name: "q", value: query)]

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        struct SearchResponse: Decodable {
            let docs: [OpenLibraryBook]
        }

        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.docs
    }
}
