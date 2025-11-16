import Combine

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published var books: [Book] = []
}
