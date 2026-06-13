import SwiftUI

protocol ListNavigationDataStore {
    func fetchRootFolder() -> Folder?
}

class ListNavigationModule {

    class func build(path: Binding<[ListNavigationPathElement]>) -> some View {
        let dataStore = ListNavigationRepository(controller: .shared)
        let viewModel = ListNavigationViewModel(path: path,
                                                dataStore: dataStore,
                                                notificationCenter: .default)
        return ListNavigationView(viewModel: viewModel)
    }
}

