enum ListItem: Hashable {
    case folder(Folder)
    case place(Placemark)
    case nearbyPlaces([PlacemarkWithDistance])

    // MARK: - Convenience

    var asFolder: Folder? {
        guard case let .folder(folder) = self else { return nil }
        return folder
    }
}

struct PlacemarkWithDistance: Hashable {
    let placemark: Placemark
    let distance: Double
}
