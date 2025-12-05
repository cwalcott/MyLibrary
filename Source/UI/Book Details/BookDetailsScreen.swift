import SwiftUI

struct BookDetailsScreen: View {
    @StateObject var viewModel: BookDetailsViewModel

    var body: some View {
        Group {
            if let book = viewModel.book {
                VStack {
                    Text(book.title)
                        .font(.largeTitle)
                    
                    if let authorNames = book.authorName?.joined(separator: ",") {
                        Text(authorNames)
                            .font(.subheadline.italic())
                    }
                }
            } else {
                Text("Loading...")
            }
        }
        .task {
            await viewModel.loadBook()
        }
    }
}

#Preview {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27482W")
        )
    }
}
