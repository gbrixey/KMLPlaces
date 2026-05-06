import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    let title: String
    var folders: [Folder] = []
    var places: [Placemark] = []
    let searchPrompt: String

    @Published var searchText = "" {
        didSet {
            updateFoldersAndPlaces()
        }
    }

    init(folder: Folder, path: Binding<[ListItem]>) {
        self.folder = folder
        _path = path
        title = folder.name ?? ""
        if folder.isRootFolder || title.isEmpty {
            searchPrompt = "Search"
        } else {
            searchPrompt = "Search in \(title)"
        }
        updateFoldersAndPlaces()
    }

    func placemarkTapped(_ placemark: Placemark) {
        path.append(.place(placemark))
    }

    func folderTapped(_ folder: Folder) {
        path.append(.folder(folder))
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
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .polygon:
            return "square.dashed"
        }
    }

    // MARK: - Private

    @Binding private var path: [ListItem]
    private let folder: Folder
    private lazy var sortedFolders: [Folder] = { folder.subfoldersArray.sortedByName }()
    private lazy var sortedPlaces: [Placemark] = { folder.placesArray.sortedByName }()
    private lazy var flattenedSubfolders: [Folder] = { folder.flattenedSubfoldersArray.sortedByName }()
    private lazy var flattenedPlaces: [Placemark] = { folder.flattenedPlacesArray.sortedByName }()

    private func updateFoldersAndPlaces() {
        if searchText.isEmpty {
            folders = sortedFolders
            places = sortedPlaces
            return
        }
        let lowercaseSearchText = searchText.lowercased()
        var subfoldersStartingWithSearchText: [Folder] = []
        var subfoldersContainingSearchText: [Folder] = []
        flattenedSubfolders.forEach { folder in
            guard let name = folder.name?.lowercased().nilIfEmpty else { return }
            if name.hasPrefix(lowercaseSearchText) {
                subfoldersStartingWithSearchText.append(folder)
            } else if name.contains(lowercaseSearchText) {
                subfoldersContainingSearchText.append(folder)
            }
        }
        folders = subfoldersStartingWithSearchText + subfoldersContainingSearchText
        var placesStartingWithSearchText: [Placemark] = []
        var placesContainingSearchText: [Placemark] = []
        flattenedPlaces.forEach { place in
            guard let name = place.name?.lowercased().nilIfEmpty else { return }
            if name.hasPrefix(lowercaseSearchText) {
                placesStartingWithSearchText.append(place)
            } else if name.contains(lowercaseSearchText) {
                placesContainingSearchText.append(place)
            }
        }
        places = placesStartingWithSearchText + placesContainingSearchText
    }
}
