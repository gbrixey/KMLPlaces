import SwiftUI
import SDWebImageSwiftUI

struct ListView: View {

    // MARK: - Public

    @Bindable var viewModel: ListViewModel

    var body: some View {
        List {
            ForEach(viewModel.folders, id: \.name) { folder in
                Button {
                    viewModel.folderTapped(folder)
                } label: {
                    FolderView(name: folder.name.nilIfEmpty ?? String(localized: .untitledFolder))
                }
            }
            ForEach(viewModel.places, id: \.id) { place in
                Button {
                    viewModel.placemarkTapped(place)
                } label: {
                    PlaceView(
                        name: place.name.nilIfEmpty ?? String(localized: .untitledPlace),
                        distance: viewModel.distanceString(for: place),
                        styleURL: viewModel.styleURL(for: place),
                        defaultIconName: viewModel.defaultIconName(for: place)
                    )
                }
            }
            if viewModel.folders.isEmpty && viewModel.places.isEmpty && !viewModel.searchText.isEmpty {
                NoMatchesView()
            }
        }
        .navigationTitle(viewModel.title)
        .searchable(text: $viewModel.searchText, prompt: viewModel.searchPrompt)
    }
}

// MARK: - Additional views

extension ListView {

    struct NoMatchesView: View {
        var body: some View {
            Text("No matching places found.")
                .frame(minHeight: 30)
                .padding(.leading, 8)
        }
    }

    struct FolderView: View {
        let name: String

        var body: some View {
            HStack(spacing: 10) {
                Image(systemName: "folder")
                    .frame(width: 30)
                    .foregroundColor(.blue)
                Text(name)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(String(localized: .folder(name)))
        }
    }

    struct PlaceView: View {
        let name: String
        let distance: String?
        let styleURL: String?
        let defaultIconName: String

        var body: some View {
            HStack(spacing: 10) {
                WebImage(url: StyleManager.shared.iconURL(styleURL: styleURL))
                    .placeholder(Image(systemName: defaultIconName))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                Text(name)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let distance = distance {
                    Text(distance)
                        .foregroundColor(.primary)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel([name, distance].withoutNils().commaSeparated)
        }
    }
}

// MARK: - Previews

#Preview {
    ListView(viewModel: ListPreviews.viewModel)
}
