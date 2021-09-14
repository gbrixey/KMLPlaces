import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            ListModule.buildNavigationView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("tab.bar.list")
                }
            MapModule.build()
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

struct RootViewPreviews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
