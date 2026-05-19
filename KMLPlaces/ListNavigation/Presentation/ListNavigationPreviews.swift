import SwiftUI

struct ListNavigationPreviews {

    static func viewModel(path: Binding<[ListItem]>) -> ListNavigationViewModel {
        let dataStore = ListNavigationRepository(controller: .preview)
        return ListNavigationViewModel(path: path, dataStore: dataStore, notificationCenter: .default)
    }
}
