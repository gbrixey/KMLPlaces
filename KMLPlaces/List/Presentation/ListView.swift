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
                    let folderName = folder.name.nilIfEmpty ?? String(localized: .untitledFolder)
                    Label(folderName, systemImage: "folder")
                        .accessibilityLabel(.folder(folderName))
                case .place(let place):
                    PlaceView(
                        name: place.name.nilIfEmpty ?? String(localized: .untitledPlace),
                        distance: viewModel.distanceString(for: place),
                        styleURL: viewModel.styleURL(for: place),
                        defaultIconName: viewModel.defaultIconName(for: place)
                    )
                }
            }
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
