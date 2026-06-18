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

    func listItemTapped(_ listItem: ListItem, at index: Int) {
        let pathElement = listItemPathElements[index]
        path.append(pathElement)
    }

    // MARK: - Private

    private let mode: ListMode

    @ObservationIgnored
    @Binding private var path: [ListNavigationPathElement]

    /// Path elements corresponding to the `self.listItems` array.
    @ObservationIgnored
    private var listItemPathElements: [ListNavigationPathElement] = []

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
        listItems = folders.map { listItem(for: $0) } + places.map { listItem(for: $0) }
        listItemPathElements = folders.map { .list(.folder($0)) } + places.map { .details($0) }
    }

    private func listItem(for folder: Folder) -> ListItem {
        let title = folder.name.nilIfEmpty ?? String(localized: .untitledFolder)
        var accessibilityLabelComponents: [String] = []
        if folder.name.isEmpty {
            accessibilityLabelComponents.append(String(localized: .untitledFolder))
        } else {
            accessibilityLabelComponents.append(String(localized: .folder(folder.name)))
        }
//        if folder.isHiddenOnMap {
//            accessibilityLabelComponents.append(String(localized: .hidden))
//        }
        return ListItem(
            imageURL: nil,
            systemImage: "folder",
            title: title,
            titleForegroundColor: .blue,
            distance: nil,
            isHiddenOnMap: false,
            accessibilityLabel: accessibilityLabelComponents.commaSeparated
        )
    }

    private func listItem(for place: Placemark) -> ListItem {
        let title = place.name.nilIfEmpty ?? String(localized: .untitledPlace)
        let (distance, distanceAccessibility) = distanceStrings(for: place)
        var accessibilityLabelComponents: [String] = [title, distanceAccessibility].withoutNils()
//        if place.isHiddenOnMap {
//            accessibilityLabelComponents.append(String(localized: .hidden))
//        }
        return ListItem(
            imageURL: iconURL(for: place),
            systemImage: defaultIconName(for: place),
            title: title,
            titleForegroundColor: .primary,
            distance: distance,
            isHiddenOnMap: false,
            accessibilityLabel: accessibilityLabelComponents.commaSeparated
        )
    }

    /// Style icon URL to use for the given placemark. For certain placemarks (polygons and polylines) we don't want to use the icon defined in the style object.
    private func iconURL(for place: Placemark) -> URL? {
        guard case .point = place.type else { return nil }
        return StyleManager.shared.iconURL(styleURL: place.styleURL)
    }

    /// System name of the image to use as a backup icon if we are not using the style icon for the given placemark.
    private func defaultIconName(for place: Placemark) -> String {
        switch place.type {
        case .point:
            return "mappin"
        case .lineString:
            return "point.bottomleft.forward.to.point.topright.scurvepath"
        case .polygon:
            return "square.dashed"
        }
    }

    private func distanceStrings(for place: Placemark) -> (distance: String?, distanceAccessibility: String?) {
        guard var distance = distanceDictionary[place.id] else { return (nil, nil) }
        var unit = UnitLength.meters
        if round(distance) >= 995 {
            distance /= 1000
            unit = .kilometers
        }
        let measurement = Measurement(value: distance, unit: unit)
        return (
            measurement.formatted(distanceFormatStyle(forAccessibility: false)),
            measurement.formatted(distanceFormatStyle(forAccessibility: true))
        )
    }

    private func distanceFormatStyle(forAccessibility: Bool) -> Measurement<UnitLength>.FormatStyle {
        let numberFormatStyle = FloatingPointFormatStyle<Double>().precision(.significantDigits(1...2))
         return Measurement<UnitLength>.FormatStyle(
            width: forAccessibility ? .wide : .abbreviated,
            usage: .asProvided,
            numberFormatStyle: numberFormatStyle
        )
    }
}

// MARK: - Subtypes

extension ListViewModel {

    struct ListItem {
        let imageURL: URL?
        let systemImage: String
        let title: String
        let titleForegroundColor: Color
        let distance: String?
        let isHiddenOnMap: Bool
        let accessibilityLabel: String
    }
}
