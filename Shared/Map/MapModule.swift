import SwiftUI

protocol MapDataStore {
    func fetchRootFolder() -> Folder?
}

class MapModule {

    class func build() -> some View {
        let dataStore = MapRepository(controller: .shared)
        let viewModel = MapViewModel(dataStore: dataStore)
        return MapView(viewModel: viewModel)
    }
}
