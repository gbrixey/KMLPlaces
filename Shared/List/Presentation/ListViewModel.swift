import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    @Published var title: String
    @Published var folders: [Folder] = []
    @Published var places: [Placemark] = []

    init(folder: Folder?,
         dataStore: ListDataStore,
         notificationCenter: NotificationCenter) {
        self.folder = folder ?? dataStore.fetchRootFolder()
        self.dataStore = dataStore
        self.notificationCenter = notificationCenter
        title = self.folder?.name ?? ""
        refreshListItems()
        notificationCenter.addObserver(self, selector: #selector(dataChanged), name: .dataChanged, object: nil)
    }

    /// Style URL to use for the given place. For certain placemarks we don't want to use the style URL.
    func styleURL(for place: Placemark) -> String? {
        guard case .point = place.type else { return nil }
        return place.styleUrl
    }

    /// System name of the image to use as a backup icon if we are not using the style icon for the given placemark.
    func defaultIconName(for place: Placemark) -> String {
        switch place.type {
        case .point:
            return "mappin"
        case .lineString:
            return "scribble"
        case .polygon:
            return "square.dashed"
        }
    }

    // MARK: - Actions

    @objc private func dataChanged() {
        folder = dataStore.fetchRootFolder()
        title = self.folder?.name ?? ""
        refreshListItems()
    }

    // MARK: - Private

    private var folder: Folder?
    private let dataStore: ListDataStore
    private let notificationCenter: NotificationCenter

    private func refreshListItems() {
        folders = folder?.subfoldersArray.sorted(by: { folder1, folder2 in
            (folder1.name ?? "") < (folder2.name ?? "")
        }) ?? []
        places = folder?.placesArray.sorted(by: { place1, place2 in
            (place1.name ?? "") < (place2.name ?? "")
        }) ?? []
    }
}
