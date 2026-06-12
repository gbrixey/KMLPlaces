import SwiftUI

struct RootView: View {

    // MARK: - Public

    @State var viewModel: RootViewModel

    var body: some View {
        @Bindable var viewModel = viewModel
        TabView {
            Tab("List", systemImage: "list.bullet") {
                ListNavigationModule.build(path: $viewModel.listPath)
            }
            Tab("Map", systemImage: "map") {
                MapModule.build(listPath: $viewModel.listPath)
            }
            Tab("Settings", systemImage: "gearshape") {
                SettingsModule.build()
            }
        }
    }
}

// MARK: - Previews

#Preview {
    RootView(viewModel: RootViewModel())
}
