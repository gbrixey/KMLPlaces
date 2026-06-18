import SwiftUI

class ListViewModel: ObservableObject {

    // MARK: - Public

    @Published var listItemDisplayModels: [ListItemDisplayModel] = []

    @Published var searchText = "" {
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

    init(mode: ListMode,
         notificationCenter: NotificationCenter,
         path: Binding<[ListNavigationPathElement]>) {
        self.mode = mode
        self.notificationCenter = notificationCenter
        _path = path
        updateListItems()
    }

    func listItemTapped(_ listItem: ListItemDisplayModel, at index: Int) {
        let model = listItemModels[index]
        switch model {
        case .folder(let folder):
            path.append(.list(.folder(folder)))
        case .place(let place):
            path.append(.details(place))
        }
    }

    /// Toggles the `isHiddenOnMap` property of the `Folder` or `Placemark` backing the list item at the given index.
    func toggleHiddenOnMap(at index: Int) {
        let model = listItemModels[index]
        switch model {
        case .folder(let folder):
            folder.isHiddenOnMap.toggle()
            notificationCenter.post(name: .isHiddenOnMapChanged, object: folder)
        case .place(let place):
            place.isHiddenOnMap.toggle()
            notificationCenter.post(name: .isHiddenOnMapChanged, object: place)
        }
        updateListItems()
    }

    // MARK: - Private

    private let mode: ListMode
    private let notificationCenter: NotificationCenter

    @Binding private var path: [ListNavigationPathElement]

    /// Models corresponding to the `self.listItemDisplayModels` array.
    private var listItemModels: [ListItemModel] = []

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
        listItemModels = folders.map { ListItemModel.folder($0) } + places.map { ListItemModel.place($0) }
        listItemDisplayModels = folders.map { displayModel(for: $0) } + places.map { displayModel(for: $0) }
    }

    private func displayModel(for folder: Folder) -> ListItemDisplayModel {
        let title = folder.name.nilIfEmpty ?? String(localized: .untitledFolder)
        var accessibilityLabelComponents: [String] = []
        if folder.name.isEmpty {
            accessibilityLabelComponents.append(String(localized: .untitledFolder))
        } else {
            accessibilityLabelComponents.append(String(localized: .folder(folder.name)))
        }
        if folder.isHiddenOnMap {
            accessibilityLabelComponents.append(String(localized: .hiddenOnMap))
        }
        return ListItemDisplayModel(
            imageURL: nil,
            systemImage: "folder",
            title: title,
            titleForegroundColor: .blue,
            distance: nil,
            isHiddenOnMap: folder.isHiddenOnMap,
            accessibilityLabel: accessibilityLabelComponents.commaSeparated
        )
    }

    private func displayModel(for place: Placemark) -> ListItemDisplayModel {
        let title = place.name.nilIfEmpty ?? String(localized: .untitledPlace)
        let (distance, distanceAccessibility) = distanceStrings(for: place)
        var accessibilityLabelComponents: [String] = [title, distanceAccessibility].withoutNils()
        if place.isHiddenOnMap {
            accessibilityLabelComponents.append(String(localized: .hiddenOnMap))
        }
        return ListItemDisplayModel(
            imageURL: iconURL(for: place),
            systemImage: defaultIconName(for: place),
            title: title,
            titleForegroundColor: .primary,
            distance: distance,
            isHiddenOnMap: place.isHiddenOnMap,
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

    enum ListItemModel {
        case folder(Folder)
        case place(Placemark)
    }

    struct ListItemDisplayModel {
        let imageURL: URL?
        let systemImage: String
        let title: String
        let titleForegroundColor: Color
        let distance: String?
        let isHiddenOnMap: Bool
        let accessibilityLabel: String

        /// Title for the swipe action that toggles the item's `isHiddenOnMap` property.
        var hideOnMapActionTitle: LocalizedStringResource {
            isHiddenOnMap ? .showOnMap : .hideOnMap
        }
    }
}
