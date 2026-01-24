import Foundation
@testable import MyLibrary

class MockURLProtocol: URLProtocol {
    static var mockResponseData: Data?
    static var mockError: Error?
    static var mockStatusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let data = MockURLProtocol.mockResponseData {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: MockURLProtocol.mockStatusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

let MOCK_BOOKS = [
    OpenLibraryBook(
        authorName: ["J.R.R. Tolkien"],
        coverEditionKey: "OL51711263M",
        key: "/works/OL27482W",
        title: "The Hobbit"
    ),
    OpenLibraryBook(
        authorName: ["J.R.R. Tolkien"],
        coverEditionKey: "OL51708686M",
        key: "/works/OL27513W",
        title: "The Fellowship of the Ring"
    ),
    OpenLibraryBook(
        authorName: ["Isaac Asimov"],
        coverEditionKey: "OL51565403M",
        key: "/works/OL46125W",
        title: "Foundation"
    ),
    OpenLibraryBook(
        authorName: ["Frank Herbert"],
        key: "/works/OL893415W",
        title: "Dune"
    ),
]
