protocol OpenLibraryAPIClient {
    func search(_ query: String) async throws -> [OpenLibraryBook]
}
