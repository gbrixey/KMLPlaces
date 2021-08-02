import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    @Published var title: String
    @Published var items: [ListItem] = []

    func itemTapped(at index: Int) {
        
    }

    init(folder: Folder?,
         dataStore: ListDataStore,
         notificationCenter: NotificationCenter) {
        self.folder = folder
        self.dataStore = dataStore
        self.notificationCenter = notificationCenter
        if folder == nil {
            self.folder = dataStore.fetchRootFolder()
        }
        title = self.folder?.name ?? ""
        refreshListItems()
        notificationCenter.addObserver(self, selector: #selector(dataChanged), name: .dataChanged, object: nil)
    }

    // MARK: - Actions

    @objc private func dataChanged() {
        refreshListItems()
    }

    // MARK: - Private

    private var folder: Folder?
    private let dataStore: ListDataStore
    private let notificationCenter: NotificationCenter

    private func refreshListItems() {
        var items: [ListItem] = []
        for subfolder in folder?.subfoldersArray ?? [] {
            guard let name = subfolder.name else { continue }
            items.append(.folder(name: name))
        }
        for place in folder?.placesArray ?? [] {
            guard let name = place.name else { continue }
            items.append(.place(name: name))
        }
        self.items = items
    }
}

// MARK: - Data types

extension ListViewModel {

    enum ListItem: Identifiable {
        case allPlaces
        case folder(name: String)
        case place(name: String)

        var id: String {
            name
        }

        var systemIcon: String {
            switch self {
            case .allPlaces, .folder:
                return "folder"
            case .place:
                return "mappin"
            }
        }

        var name: String {
            switch self {
            case .allPlaces:
                return NSLocalizedString("list.all.places", comment: "")
            case let .folder(name):
                return name
            case let .place(name):
                return name
            }
        }

        var nameColor: Color {
            switch self {
            case .allPlaces, .folder:
                return .blue
            case .place:
                return .primary
            }
        }
    }
}
