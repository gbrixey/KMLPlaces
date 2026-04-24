import SwiftUI

class ListModule {

    class func build(folder: Folder? = nil, path: Binding<[ListItem]>) -> some View {
        let viewModel = ListViewModel(folder: folder, path: path)
        return ListView(viewModel: viewModel)
    }
}
