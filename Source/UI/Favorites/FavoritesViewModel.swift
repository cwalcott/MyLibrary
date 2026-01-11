import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var books: [Book] = []

    init(database: AppDatabase) {
        database.books().streamAll().assign(to: &$books)
    }
}
