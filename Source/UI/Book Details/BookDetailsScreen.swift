import SwiftUI

struct BookDetailsScreen: View {
    @StateObject var viewModel: BookDetailsViewModel

    var body: some View {
        ZStack {
            if let book = viewModel.state {
                VStack {
                    Text(book.title)
                        .font(.largeTitle)
                    
                    if let authorNames = book.authorNames {
                        Text(authorNames)
                            .font(.subheadline.italic())
                    }
                }

                Group {
                    if book.isFavorite {
                        Button("Remove from Favorites") {
                            viewModel.removeFromFavorites()
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button("Add to Favorites") {
                            viewModel.addToFavorites()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
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
