import SwiftUI

struct ListView: View {
    @StateObject var viewModel: ListViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(enumeratedItems, id: \.0) { index, item in
                    ListItemView(item: item, onTap: {
                        viewModel.itemTapped(at: index)
                    })
                }
            }
            // TODO: Add .searchable in iOS 15
            .navigationTitle(viewModel.title)
        }
    }

    private var enumeratedItems: [(index: Int, item: ListViewModel.ListItem)] {
        viewModel.items.enumerated().map { ($0, $1) }
    }
}

// MARK: - Additional views

extension ListView {

    struct ListItemView: View {
        let item: ListViewModel.ListItem
        let onTap: () -> Void

        var body: some View {
            HStack(spacing: 0) {
                Image(systemName: item.icon)
                    .frame(width: 50)
                    .foregroundColor(item.nameColor)
                Text(item.name)
                    .foregroundColor(item.nameColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ForEach(item.colors.prefix(3), id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                        .padding(4)
                }
            }
            .onTapGesture(perform: onTap)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item.name)
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(viewModel: ListViewModel())
    }
}