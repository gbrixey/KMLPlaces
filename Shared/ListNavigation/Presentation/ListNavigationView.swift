import SwiftUI

struct ListNavigationView: View {

    // MARK: - Public

    @ObservedObject var viewModel: ListNavigationViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ListModule.build(folder: viewModel.rootFolder, path: $viewModel.path)
                .navigationDestination(for: ListItem.self) { listItem in
                    switch listItem {
                    case .folder(let folder):
                        ListModule.build(folder: folder, path: $viewModel.path)
                    case .place(let place):
                        DetailsModule.build(place: place)
                    }
                }
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var path: [ListItem] = []
    ListNavigationView(viewModel: ListNavigationPreviews.viewModel(path: $path))
}
