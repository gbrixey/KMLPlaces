import SwiftUI

struct ListNavigationView: View {

    // MARK: - Public

    @ObservedObject var viewModel: ListNavigationViewModel

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            if let rootFolder = viewModel.rootFolder {
                ListModule.build(folder: rootFolder, path: $viewModel.path)
                    .navigationDestination(for: ListItem.self) { listItem in
                        switch listItem {
                        case .folder(let folder):
                            ListModule.build(folder: folder, path: $viewModel.path)
                        case .place(let place):
                            DetailsModule.build(place: place)
                        }
                    }
            } else {
                PlaceholderView()
            }
        }
    }
}

// MARK: - Additional views

extension ListNavigationView {

    struct PlaceholderView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "questionmark.circle.dashed")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text("No place data")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Import a KML file from Settings\u{00a0}\(Image(systemName: "gearshape.fill"))\nto see your places here.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    @Previewable @State var path: [ListItem] = []
    ListNavigationView(viewModel: ListNavigationPreviews.viewModel(path: $path))
}
