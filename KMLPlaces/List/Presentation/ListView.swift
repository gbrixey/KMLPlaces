import SwiftUI
import SDWebImageSwiftUI

struct ListView: View {

    // MARK: - Public

    @Bindable var viewModel: ListViewModel

    var body: some View {
        List {
            ForEach(viewModel.listItems, id: \.id) { item in
                ListItemButton(listItem: item, viewModel: viewModel)
            }
            if viewModel.listItems.isEmpty && !viewModel.searchText.isEmpty {
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

    struct ListItemButton: View {
        let listItem: ListViewModel.ListItem
        let viewModel: ListViewModel

        var body: some View {
            Button {
                viewModel.listItemTapped(listItem)
            } label: {
                switch listItem {
                case .folder(let folder):
                    FolderView(folder: folder)
                case .place(let place):
                    PlaceView(place: place, viewModel: viewModel
                    )
                }
            }
        }
    }

    struct FolderView: View {
        let folder: Folder

        var body: some View {
            Label(name, systemImage: "folder")
                .accessibilityLabel(accessibilityLabel)
        }

        private var name: String {
            folder.name.nilIfEmpty ?? String(localized: .untitledFolder)
        }

        private var accessibilityLabel: String {
            if folder.name.isEmpty {
                return String(localized: .untitledFolder)
            } else {
                return String(localized: .folder(folder.name))
            }
        }
    }

    struct PlaceView: View {
        let place: Placemark
        let viewModel: ListViewModel

        var body: some View {
            let name = place.name.nilIfEmpty ?? String(localized: .untitledPlace)
            let distance = viewModel.distanceString(for: place)
            let styleURL = viewModel.styleURL(for: place)
            let defaultIconName = viewModel.defaultIconName(for: place)

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
