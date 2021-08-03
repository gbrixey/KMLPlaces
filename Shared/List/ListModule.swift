import SwiftUI

protocol ListDataStore {
    func fetchRootFolder() -> Folder?
}

class ListModule {

    class func build(folder: Folder? = nil) -> some View {
        let dataStore = ListRepository(controller: .shared)
        let viewModel = ListViewModel(folder: folder,
                                      dataStore: dataStore,
                                      notificationCenter: .default)
        return ListView(viewModel: viewModel)
    }

    class func buildNavigationView(folder: Folder? = nil) -> some View {
        let dataStore = ListRepository(controller: .shared)
        let viewModel = ListViewModel(folder: folder,
                                      dataStore: dataStore,
                                      notificationCenter: .default)
        return ListNavigationView(viewModel: viewModel)
    }
}
