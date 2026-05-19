import SwiftUI

class ListNavigationViewModel: ObservableObject {

    // MARK: - Public

    @Binding var path: [ListItem]
    @Published private(set) var rootFolder: Folder?

    init(path: Binding<[ListItem]>,
         dataStore: ListNavigationDataStore,
         notificationCenter: NotificationCenter) {
        self._path = path
        self.dataStore = dataStore
        self.rootFolder = dataStore.fetchRootFolder()
        notificationCenter.addObserver(self, selector: #selector(dataChanged), name: .dataChanged, object: nil)
    }

    // MARK: - Actions

    @objc private func dataChanged() {
        path.removeAll()
        rootFolder = dataStore.fetchRootFolder()
    }

    // MARK: - Private

    private let dataStore: ListNavigationDataStore
}
