import SwiftUI

struct SearchBooksScreen: View {
    @StateObject var viewModel: SearchBooksViewModel

    var body: some View {
        List(viewModel.books) { book in
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)

                if let author = book.authorName?.first {
                    Text(author)
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Books")
        .searchable(text: $viewModel.searchQuery)
    }
}

#Preview {
    NavigationView {
        SearchBooksScreen(
            viewModel: SearchBooksViewModel()
        )
    }
}
