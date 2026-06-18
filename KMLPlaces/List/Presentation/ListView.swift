import SwiftUI
import SDWebImageSwiftUI

struct ListView: View {

    // MARK: - Public

    @ObservedObject var viewModel: ListViewModel

    var body: some View {
        List {
            ForEach(viewModel.listItemDisplayModels.enumerated(), id: \.0) { (index, item) in
                Button {
                    viewModel.listItemTapped(item, at: index)
                } label: {
                    ListItemView(listItem: item)
                }
                .swipeActions {
                    Button {
                        viewModel.toggleHiddenOnMap(at: index)
                    } label: {
                        Label {
                            Text(item.hideOnMapActionTitle)
                        } icon: {
                            Image(systemName: item.isHiddenOnMap ? "eye" : "eye.slash")
                        }
                    }
                }
            }
            if viewModel.listItemDisplayModels.isEmpty && !viewModel.searchText.isEmpty {
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

    struct ListItemView: View {
        let listItem: ListViewModel.ListItemDisplayModel

        var body: some View {
            HStack(spacing: 10) {
                Label {
                    Text(listItem.title)
                        .lineLimit(2)
                        .foregroundStyle(listItem.titleForegroundColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } icon: {
                    if let url = listItem.imageURL {
                        WebImage(url: url)
                            .placeholder(Image(systemName: listItem.systemImage))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                    } else {
                        Image(systemName: listItem.systemImage)
                    }
                }
                if let distance = listItem.distance {
                    Text(distance)
                        .foregroundStyle(Color.primary)
                } else if listItem.isHiddenOnMap {
                    Image(systemName: "eye.slash")
                        .foregroundStyle(.gray)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(listItem.accessibilityLabel)
        }
    }
}

// MARK: - Previews

#Preview {
    StyleManager.shared.loadStyles(persistenceController: .preview)
    return ListView(viewModel: ListPreviews.viewModel)
}
