enum ListMode: Hashable {
    case folder(Folder)
    case nearbyPlaces([PlacemarkWithDistance])
}

enum ListNavigationPathElement: Hashable {
    case list(ListMode)
    case details(Placemark)

    // MARK: - Convenience

    var asFolder: Folder? {
        guard case let .list(.folder(folder)) = self else { return nil }
        return folder
    }
}

struct PlacemarkWithDistance: Hashable {
    let placemark: Placemark
    let distance: Double
}
