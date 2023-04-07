import SwiftUI

protocol MapDataStore {
    func fetchRootFolder() -> Folder?
}

class MapModule {

    class func build() -> some View {
        let dataStore = MapRepository(controller: .shared)
        let viewModel = MapViewModel(dataStore: dataStore,
                                     notificationCenter: .default)
        return MapView(viewModel: viewModel)
    }
}
