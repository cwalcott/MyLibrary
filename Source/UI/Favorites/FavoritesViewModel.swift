import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var books: [Book]?

    init(database: AppDatabase) {
        database.books().streamAll().map { $0 as [Book]? }.assign(to: &$books)
    }
}
