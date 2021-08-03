import SwiftUI

struct ListView: View {

    // MARK: - Public

    @StateObject var viewModel: ListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.folders, id: \.name) { folder in
                NavigationLink(destination: ListModule.build(folder: folder)) {
                    FolderView(name: folder.name ?? String(key: "default.folder.name"))
                }
            }
            ForEach(viewModel.places, id: \.id) { place in
                NavigationLink(destination: DetailsModule.build(place: place)) {
                    PlaceView(name: place.name ?? String(key: "default.placemark.name"))
                }
            }
        }
        // TODO: Add .searchable in iOS 15
        .navigationTitle(viewModel.title)
    }
}

// MARK: - Additional views

extension ListView {

    struct FolderView: View {
        let name: String

        var body: some View {
            HStack(spacing: 0) {
                Image(systemName: "folder")
                    .frame(width: 50)
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

        var body: some View {
            HStack(spacing: 0) {
                Image(systemName: "mappin")
                    .frame(width: 50)
                    .foregroundColor(.primary)
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

struct ListViewPreviews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListPreviews.viewModel)
    }
}
