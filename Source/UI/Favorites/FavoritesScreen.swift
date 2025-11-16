import SwiftUI

struct FavoritesScreen: View {
    @StateObject var viewModel: FavoritesViewModel

    @State private var showingSearch = false

    @Environment(\.composer) private var composer

    var body: some View {
        List(viewModel.books) { book in
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                if let author = book.author {
                    Text(author)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Favorite Books")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            NavigationStack {
                SearchBooksScreen(viewModel: composer.makeSearchBooksViewModel())
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showingSearch = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        FavoritesScreen(viewModel: composer.makeFavoritesViewModel())
    }
}
