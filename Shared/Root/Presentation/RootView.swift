import SwiftUI

struct RootView: View {

    // MARK: - Public

    @StateObject var viewModel: RootViewModel

    var body: some View {
        TabView {
            ListNavigationModule.build(path: $viewModel.listPath)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("tab.bar.list")
                }
            MapModule.build(listPath: $viewModel.listPath)
                .tabItem {
                    Image(systemName: "map")
                    Text("tab.bar.map")
                }
            SettingsModule.build()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("tab.bar.settings")
                }
        }
    }
}

// MARK: - Previews

#Preview {
    RootView(viewModel: RootViewModel())
}
