import GRDB
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
        .alert(
            viewModel.errorMessage ?? "",
            isPresented: .constant(viewModel.errorMessage != nil)
        ) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        }
        .task {
            await viewModel.loadBook()
        }
    }
}

#Preview("Favorite") {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27482W")
        )
    }
}

#Preview("Not favorite") {
    @Previewable @Environment(\.composer) var composer

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
    }
}

#Preview("DB Error") {
    let composer = Composer.preview {
        try! $0.database.dbQueue.write { db in
            try db.execute(sql: "DROP TABLE books")
        }
    }

    NavigationStack {
        BookDetailsScreen(
            viewModel: composer.makeBookDetailsViewModel(openLibraryKey: "/works/OL27513W")
        )
        .environment(\.composer, composer)
    }
}
