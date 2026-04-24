import SwiftUI
import SDWebImageSwiftUI

struct ListView: View {

    // MARK: - Public

    @ObservedObject var viewModel: ListViewModel

    var body: some View {
        List {
            ForEach(viewModel.folders, id: \.name) { folder in
                Button {
                    viewModel.folderTapped(folder)
                } label: {
                    FolderView(name: folder.name ?? String(key: "default.folder.name"))
                }
            }
            ForEach(viewModel.places, id: \.id) { place in
                Button {
                    viewModel.placemarkTapped(place)
                } label: {
                    PlaceView(name: place.name ?? String(key: "default.placemark.name"),
                              styleURL: viewModel.styleURL(for: place),
                              defaultIconName: viewModel.defaultIconName(for: place))
                }
            }
        }
        .overlay {
            if viewModel.folders.isEmpty && viewModel.places.isEmpty {
                PlaceholderView()
            }
        }
        // TODO: Add .searchable in iOS 15
        .navigationTitle(viewModel.title)
    }
}

// MARK: - Additional views

extension ListView {

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

    struct FolderView: View {
        let name: String

        var body: some View {
            HStack(spacing: 0) {
                Image(systemName: "folder")
                    .frame(width: 30)
                    .padding(.trailing, 10)
                    .foregroundColor(.blue)
                Text(name)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(name)
        }
    }

    struct PlaceView: View {
        let name: String
        let styleURL: String?
        let defaultIconName: String

        var body: some View {
            HStack(spacing: 0) {
                WebImage(url: StyleManager.shared.iconURL(styleURL: styleURL))
                    .placeholder(Image(systemName: defaultIconName))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 10)
                Text(name)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(name)
        }
    }
}

// MARK: - Previews

#Preview {
    ListView(viewModel: ListPreviews.viewModel)
}
