import SwiftUI

@Observable class ListViewModel {

    // MARK: - Public

    var listItems: [ListItem] = []

    var searchText = "" {
        didSet {
            updateListItems()
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

    init(mode: ListMode, path: Binding<[ListNavigationPathElement]>) {
        self.mode = mode
        _path = path
        updateListItems()
    }

    func listItemTapped(_ listItem: ListItem) {
        path.append(listItem.pathElement)
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
        guard var distance = distanceDictionary[place.id] else { return nil }
        var unit = UnitLength.meters
        if round(distance) >= 995 {
            distance /= 1000
            unit = .kilometers
        }
        let measurement = Measurement(value: distance, unit: unit)
        return measurement.formatted(distanceFormatStyle)
    }

    // MARK: - Private

    @ObservationIgnored
    @Binding private var path: [ListNavigationPathElement]
    private let mode: ListMode

    @ObservationIgnored
    private lazy var distanceFormatStyle: Measurement<UnitLength>.FormatStyle = {
        let numberFormatStyle = FloatingPointFormatStyle<Double>().precision(.significantDigits(1...2))
        return .init(width: .abbreviated, usage: .asProvided, numberFormatStyle: numberFormatStyle)
    }()

    @ObservationIgnored
    private lazy var sortedFolders: [Folder] = {
        switch mode {
        case .folder(let folder):
            return folder.subfolders.sortedByName
        case .nearbyPlaces:
            return []
        }
    }()

    @ObservationIgnored
    private lazy var sortedPlaces: [Placemark] = {
        switch mode {
        case .folder(let folder):
            return folder.places.sortedByName
        case .nearbyPlaces(let placesWithDistance):
            return placesWithDistance.map { $0.placemark }
        }
    }()

    @ObservationIgnored
    private lazy var flattenedSubfolders: [Folder] = {
        switch mode {
        case .folder(let folder):
            return folder.flattenedSubfolders.sortedByName
        case .nearbyPlaces:
            return []
        }
    }()

    @ObservationIgnored
    private lazy var flattenedPlaces: [Placemark] = {
        switch mode {
        case .folder(let folder):
            return folder.flattenedPlaces.sortedByName
        case .nearbyPlaces(let placesWithDistance):
            return placesWithDistance.map { $0.placemark }
        }
    }()

    @ObservationIgnored
    private lazy var distanceDictionary: [AnyHashable: Double] = {
        guard case let .nearbyPlaces(placesWithDistance) = mode else {
            return [:]
        }
        var dict: [AnyHashable: Double] = [:]
        placesWithDistance.forEach { dict[$0.placemark.id] = $0.distance }
        return dict
    }()

    private func updateListItems() {
        let folders: [Folder]
        let places: [Placemark]
        if searchText.isEmpty {
            folders = sortedFolders
            places = sortedPlaces
        } else {
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
        listItems = folders.map { .folder($0) } + places.map { .place($0) }
    }
}

// MARK: - Subtypes

extension ListViewModel {

    enum ListItem: Identifiable {
        case folder(Folder)
        case place(Placemark)

        var id: some Hashable {
            switch self {
            case .folder(let folder):
                return folder.id
            case .place(let placemark):
                return placemark.id
            }
        }

        var isHidden: Bool {
            switch self {
            case .folder(let folder):
                return folder.isHidden
            case .place(let placemark):
                return placemark.isHidden
            }
        }

        var pathElement: ListNavigationPathElement {
            switch self {
            case .folder(let folder):
                return .list(.folder(folder))
            case .place(let placemark):
                return .details(placemark)
            }
        }
    }
}
