import SwiftUI

class ListModule {

    class func build(mode: ListMode, path: Binding<[ListNavigationPathElement]>) -> some View {
        let viewModel = ListViewModel(mode: mode, path: path)
        return ListView(viewModel: viewModel)
    }
}
