import SwiftUI

enum ListMode {
    case folder(Folder)
    case nearbyPlaces([PlacemarkWithDistance])
}

class ListModule {

    class func build(mode: ListMode, path: Binding<[ListItem]>) -> some View {
        let viewModel = ListViewModel(mode: mode, path: path)
        return ListView(viewModel: viewModel)
    }
}
