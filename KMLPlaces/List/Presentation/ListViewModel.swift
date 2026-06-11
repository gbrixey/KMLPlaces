import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    var folders: [Folder] = []
    var places: [Placemark] = []

    @Published var searchText = "" {
        didSet {
            updateFoldersAndPlaces()
        }
    }

    var title: String {
        switch mode {
        case .folder(let folder):
            return folder.name
        case .nearbyPlaces:
            return "Nearby Places"
        }
    }

    var searchPrompt: String {
        switch mode {
        case .folder(let folder):
            if folder.isRootFolder || folder.name.isEmpty {
                return "Search"
            } else {
                return "Search in \(title)"
            }
        case .nearbyPlaces:
            return "Search"
        }
    }

    init(mode: ListMode, path: Binding<[ListItem]>) {
        self.mode = mode
        _path = path
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
        return place.styleURL
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

    func distanceString(for place: Placemark) -> String? {
        guard let distance = distanceDictionary[place.id] else { return nil }
        return measurementFormatter.string(from: Measurement(value: distance, unit: UnitLength.meters))
    }

    // MARK: - Private

    @Binding private var path: [ListItem]
    private let mode: ListMode

    private lazy var measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.usesSignificantDigits = true
        formatter.numberFormatter.maximumSignificantDigits = 2
        return formatter
    }()

    private lazy var sortedFolders: [Folder] = {
        switch mode {
        case .folder(let folder):
            return folder.subfolders.sortedByName
        case .nearbyPlaces:
            return []
        }
    }()

    private lazy var sortedPlaces: [Placemark] = {
        switch mode {
        case .folder(let folder):
            return folder.places.sortedByName
        case .nearbyPlaces(let placesWithDistance):
            return placesWithDistance.map { $0.placemark }
        }
    }()

    private lazy var flattenedSubfolders: [Folder] = {
        switch mode {
        case .folder(let folder):
            return folder.flattenedSubfolders.sortedByName
        case .nearbyPlaces:
            return []
        }
    }()

    private lazy var flattenedPlaces: [Placemark] = {
        switch mode {
        case .folder(let folder):
            return folder.flattenedPlaces.sortedByName
        case .nearbyPlaces(let placesWithDistance):
            return placesWithDistance.map { $0.placemark }
        }
    }()

    private lazy var distanceDictionary: [AnyHashable: Double] = {
        guard case let .nearbyPlaces(placesWithDistance) = mode else {
            return [:]
        }
        var dict: [AnyHashable: Double] = [:]
        placesWithDistance.forEach { dict[$0.placemark.id] = $0.distance }
        return dict
    }()

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
            guard let name = folder.name.lowercased().nilIfEmpty else { return }
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
            guard let name = place.name.lowercased().nilIfEmpty else { return }
            if name.hasPrefix(lowercaseSearchText) {
                placesStartingWithSearchText.append(place)
            } else if name.contains(lowercaseSearchText) {
                placesContainingSearchText.append(place)
            }
        }
        places = placesStartingWithSearchText + placesContainingSearchText
    }
}
