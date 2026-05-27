import SwiftUI

protocol MapDataStore {
    func fetchRootFolder() -> Folder?
    func requestLocationAuthorization()
}

class MapModule {

    class func build(listPath: Binding<[ListItem]>) -> some View {
        let dataStore = MapRepository(controller: .shared)
        let viewModel = MapViewModel(listPath: listPath,
                                     dataStore: dataStore,
                                     notificationCenter: .default)
        return MapView(viewModel: viewModel)
    }
}
